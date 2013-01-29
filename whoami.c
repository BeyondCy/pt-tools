#include <windows.h>
#include <stdio.h> 

#pragma comment(lib,"Advapi32.lib")

#define MAX_SIZE   100

static void print_error(char *msg);

int main(int argc, char **argv) {
    char buffer[MAX_SIZE];
    DWORD nSize = MAX_SIZE;

    if (GetUserName(buffer, &nSize)) {
        printf("%s\n", buffer);
    } else {
        print_error("GetUserName");
    }

    return 0;
}

static void print_error(char *msg) {
    DWORD eNum;
    TCHAR sysMsg[256];
    TCHAR* p;

    eNum = GetLastError( );
    FormatMessage( FORMAT_MESSAGE_FROM_SYSTEM |
            FORMAT_MESSAGE_IGNORE_INSERTS,
            NULL, eNum,
            MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
            sysMsg, 256, NULL );

    printf("\t%s failed with error %d (%s)", msg, eNum, sysMsg );
}
