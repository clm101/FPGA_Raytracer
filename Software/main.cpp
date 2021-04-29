#define NOMINMAX
#include <Windows.h>
#include <iostream>
#include <exception>
#include <sstream>
#include <optional>
#include <bit>
#include <array>
#include <limits>

#define TEST_ECHO 0
#define TEST_CTRL 1

constexpr size_t nByteCount = 35558;
namespace clm {
	class FPGAException : public std::exception {
	public:
		FPGAException(std::string msg) : std::exception(), m_msg(msg) {
			LPSTR ptrMsg = nullptr;
			m_msg += "\nError Information:\n";
			if (FormatMessageA(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
				NULL,
				GetLastError(),
				LocaleNameToLCID(LOCALE_NAME_SYSTEM_DEFAULT, LOCALE_ALLOW_NEUTRAL_NAMES),
				reinterpret_cast<LPSTR>(&ptrMsg),
				0,
				nullptr) == 0)
			{
				m_msg += "Unknown error code";
			}
			else {
				m_msg += ptrMsg;
			}
			LocalFree(ptrMsg);
		}
		virtual const char* what() const noexcept override {
			return m_msg.c_str();
		}
	private:
		std::string m_msg;
	};

	enum class BaudRate {
		BR_9600,
		BR_19200
	};

	class FPGA {
	public:
		FPGA(const BaudRate br = BaudRate::BR_9600) {
			// Connect to FPGA
			m_hFPGA = CreateFile(L"\\\\.\\COM4",
				GENERIC_READ | GENERIC_WRITE,
				0,
				NULL,
				OPEN_EXISTING,
				FILE_ATTRIBUTE_NORMAL,
				NULL
			);
			if (m_hFPGA == INVALID_HANDLE_VALUE) {
				throw FPGAException{ "Error creating file handle" };
			}
#ifdef _DEBUG
			std::cout << "Valid handle to FPGA\n";
#endif

			// Get and set connection information
			// There's more to do here, but first I need to figure out how I want to handle control messages
			DCB dcb{};
			dcb.DCBlength = sizeof(DCB);
			if (GetCommState(m_hFPGA, &dcb) == 0) {
				throw FPGAException{ "Error getting default DCB information" };
			}
			dcb.fOutxCtsFlow = FALSE;
			dcb.fOutxDsrFlow = FALSE;
			dcb.fDtrControl = DTR_CONTROL_DISABLE;
			dcb.fParity = FALSE;
			dcb.Parity = NOPARITY;
			dcb.StopBits = ONESTOPBIT;
			dcb.ByteSize = 8;
			dcb.fNull = FALSE;

			switch (br) {
			case BaudRate::BR_9600:
				dcb.BaudRate = CBR_9600;
				break;
			case BaudRate::BR_19200:
				dcb.BaudRate = CBR_19200;
				break;
			default:
				dcb.BaudRate = CBR_9600;
				break;
			}

			if (SetCommState(m_hFPGA, &dcb) == 0) {
				throw FPGAException{ "Error setting DCB information" };
			}

			COMMPROP comProp{};
			if (GetCommProperties(m_hFPGA, &comProp) == 0) {
				throw FPGAException{ "Error getting Comm properties" };
			}
			std::cout << "Size of Tx queue: " << comProp.dwMaxTxQueue << " bytes\n";
			std::cout << "Size of Rx queue: " << comProp.dwMaxRxQueue << " bytes\n";
			std::cout << "Max baud rate: " << std::hex << comProp.dwMaxBaud << '\n';
			std::cout << "Comm-provider type: " << std::hex << comProp.dwProvSubType << '\n';
		}
		~FPGA() {
			if (m_hFPGA != NULL) {
				CloseHandle(m_hFPGA);
			}
		}
		template<typename T>
		void buffer_insert(T t) {
			std::array<std::byte, sizeof(T)> txBufferPrep = std::bit_cast<std::array<std::byte, sizeof(T)>>(t);
			DWORD dwBytesSent = 0;
			if (WriteFile(m_hFPGA, txBufferPrep.data(), sizeof(T), &dwBytesSent, NULL) == 0) {
				throw FPGAException{ "Error writing buffer" };
			}
		}
		bool buffer_check() {
			return true;
		}
		std::optional<std::byte> buffer_read() {
			std::byte buffer;
			//static size_t cnt = 0;
			DWORD dwBytesRead = 0;
			if (ReadFile(m_hFPGA, &buffer, 1, &dwBytesRead, NULL) == 0) {
				throw FPGAException{ "Error reading buffer" };
			}
			return dwBytesRead == 0 ? std::optional<std::byte>{} : buffer;
		}

		void send_ctrl1() {
			buffer_insert(CtrlBytes::Ctrl1);
		}
		void send_ctrl2() {
			buffer_insert(CtrlBytes::Ctrl2);
		}
		void send_ctrl3() {
			buffer_insert(CtrlBytes::Ctrl3);
		}
		void send_uint(std::uint32_t n) {
			buffer_insert(CtrlBytes::ECHO);
			buffer_insert(n);
		}
		void add_ints(std::int32_t n1, std::int32_t n2) {
			buffer_insert(CtrlBytes::ADD);
			buffer_insert(n1);
			buffer_insert(n2);
		}
		void mul_ints(std::int32_t n1, std::int32_t n2) {
			buffer_insert(CtrlBytes::MUL);
			buffer_insert(n1);
			buffer_insert(n2);
		}
	private:
		HANDLE m_hFPGA;
		enum class CtrlBytes : char {
			Ctrl1 = 0x01,
			Ctrl2 = 0x02,
			Ctrl3 = 0x03,
			ECHO = 0x04,
			ADD = 0x05,
			MUL = 0x06
		};
	};
}

int main() {
	std::array<std::byte, 4> fp = std::bit_cast<std::array<std::byte, 4>>(3.0f);
	std::array<std::byte, 4> fp2 = std::bit_cast<std::array<std::byte, 4>>(5.34f);
	std::array<std::byte, 4> fp3 = std::bit_cast<std::array<std::byte, 4>>(3.0f + 5.34f);
#if TEST_ECHO
	std::array<std::byte, nByteCount> txBuffer{};
	std::array<std::byte, nByteCount> rxBuffer{};
#endif
	size_t nBytesTx = 0;
	size_t nBytesRx = 0;

	try {
		clm::FPGA fpga{clm::BaudRate::BR_19200};
#if TEST_ECHO
		for (size_t i = 0; i < nByteCount; i++) {
			txBuffer[i] = static_cast<std::byte>(i % 256);
			rxBuffer[i] = std::byte{ '\0' };
		}

		constexpr size_t nMaxJobSize = 10000;
		constexpr size_t nGroupCount = nByteCount / nMaxJobSize;
		bool bExitLoop = false;
		std::cout << std::dec;
		for (size_t i = 0; i <= nGroupCount; i++) {
			size_t nIterCount = std::min(nMaxJobSize, nByteCount - nMaxJobSize * i);
			std::cout << "Sending...";
			for (nBytesTx = 0; nBytesTx < nIterCount; nBytesTx++) {
				fpga.buffer_insert(txBuffer[nBytesTx + i * nMaxJobSize]);
			}
			std::cout << nBytesTx << " bytes\nReceiving...";
			for (nBytesRx = 0; nBytesRx < nIterCount; nBytesRx++) {
				if (std::optional<std::byte> oc = fpga.buffer_read()) {
					rxBuffer[nBytesRx + i * nMaxJobSize] = oc.value();
				}
				else {
					std::cout << "No byte received\n";
					bExitLoop = true;
					break;
				}
			}
			std::cout << nBytesRx << " bytes\n";
			if (bExitLoop) break;
		}
#endif
#if TEST_CTRL
		std::array<std::byte, 2> rx{};
		std::array<std::byte, 4> rx_int{};
		std::array<std::byte, 4> rx_int2{};
		std::array<std::byte, 4> rx_int3{};
		std::array<std::byte, 4> rx_int4{};
		std::array<std::byte, 4> rx_int5{};
		fpga.send_ctrl1();
		if (std::optional<std::byte> ret = fpga.buffer_read()) {
			rx[0] = ret.value();
		}
		fpga.send_ctrl2();
		if (std::optional<std::byte> ret = fpga.buffer_read()) {
			rx[1] = ret.value();
		}
		fpga.send_uint(345);
		for (size_t i = 0; i < 4; i++) {
			if (auto ret = fpga.buffer_read()) {
				rx_int[i] = ret.value();
			}
			else {
				std::cout << "Error reading back int";
			}
		}
		fpga.send_uint(23453);
		for (size_t i = 0; i < 4; i++) {
			if (auto ret = fpga.buffer_read()) {
				rx_int2[i] = ret.value();
			}
			else {
				std::cout << "Error reading back int";
			}
		}
		fpga.send_uint(std::numeric_limits<std::uint32_t>::max());
		for (size_t i = 0; i < 4; i++) {
			if (auto ret = fpga.buffer_read()) {
				rx_int3[i] = ret.value();
			}
			else {
				std::cout << "Error reading back int";
			}
		}
		fpga.add_ints(-1258, 45);
		for (size_t i = 0; i < 4; i++) {
			if (auto ret = fpga.buffer_read()) {
				rx_int4[i] = ret.value();
			}
			else {
				std::cout << "Error reading back int";
			}
		}
		/*fpga.mul_ints(23, 7);
		for (size_t i = 0; i < 4; i++) {
			if (auto ret = fpga.buffer_read()) {
				rx_int5[i] = ret.value();
			}
			else {
				std::cout << "Error reading back int";
			}
		}*/


		int x = 2; // breakpoint
#endif
	}
	catch (const clm::FPGAException& e) {
		std::cout << e.what();
		return -1;
	}
	catch (...) {
		std::cout << "Unknown exception caught\n";
		return -2;
	}
#if TEST_ECHO
	std::cout << "Verifying...\n";
	bool bCorrect = true;
	for (size_t i = 0; i < nByteCount; i++) {
		if (txBuffer[i] != rxBuffer[i]) {
			std::cout << "Incorrect byte received. Byte " << i + 1 << " : " << static_cast<char>(rxBuffer[i]) << " and " << static_cast<char>(txBuffer[i]) << '\n';
			bCorrect = false;
			break;
		}
	}
	std::cout << (bCorrect ? "Test passed\n" : "Test failed\n");
#endif
	return 0;
}