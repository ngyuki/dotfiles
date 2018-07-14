#include <windows.h>
#include <shellapi.h>

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
    STARTUPINFO si = { sizeof(STARTUPINFO) };
    si.wShowWindow =  SW_SHOWDEFAULT;

    PROCESS_INFORMATION pi = {0};

    BOOL re = CreateProcessA(
        NULL,
        lpCmdLine,
        NULL,
        NULL,
        FALSE,
        CREATE_DEFAULT_ERROR_MODE,
        NULL,
        NULL,
        &si,
        &pi
    );

    if (re == FALSE) {
        LPVOID lpMsgBuf;
        DWORD len = FormatMessage(
            FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
            NULL,
            GetLastError(),
            MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
            (LPTSTR) &lpMsgBuf,
            0,
            NULL
        );
        if (len) {
            MessageBox(NULL, (LPCTSTR)lpMsgBuf, "Error", MB_OK | MB_ICONINFORMATION);
            LocalFree(lpMsgBuf);
        } else {
            MessageBox(NULL, "Unknown error", "Error", MB_OK | MB_ICONINFORMATION);
        }
    }
    return 0;
};
