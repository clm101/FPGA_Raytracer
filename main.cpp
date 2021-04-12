#include <Windows.h>
#include <iostream>
#include <exception>
#include <sstream>

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
		BR_9600
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
			default:
				dcb.BaudRate = CBR_9600;
				break;
			}

			if (SetCommState(m_hFPGA, &dcb) == 0) {
				throw FPGAException{ "Error setting default DCB information" };
			}
		}
		~FPGA() {
			if (m_hFPGA != NULL) {
				CloseHandle(m_hFPGA);
			}
		}
		// Potentially template in the future
		void buffer_insert(const char c) {
			DWORD dwBytesSent = 0;
			if (WriteFile(m_hFPGA, &c, 1, &dwBytesSent, NULL) == 0) {
				throw FPGAException{ "Error writing buffer" };
			}
		}
		bool buffer_check() {
			return true;
		}
		void buffer_read() {
			LPVOID ptrBuffer = nullptr;
			DWORD dwBytesRead = 0;
			if (ReadFile(m_hFPGA, &ptrBuffer, 1, &dwBytesRead, NULL) == 0) {
				throw FPGAException{ "Error reading buffer" };
			}
			else {
				std::cout << "Reading->";
				if (dwBytesRead != 0) {
					for (DWORD i = 0; i < dwBytesRead; i++) {
						std::cout << "Byte read: " << *reinterpret_cast<char*>(&ptrBuffer) << '\n';
					}
				}
			}
			return;
		}
	private:
		HANDLE m_hFPGA;
	};
}

int main() {

	try {
		clm::FPGA fpga{};
		while (true) {
			fpga.buffer_insert('a');
			fpga.buffer_read();
		}
	}
	catch (const clm::FPGAException& e) {
		std::cout << e.what();
	}
	catch (...) {
		std::cout << "Unknown exception caught\n";
	}
	

	return 0;
}