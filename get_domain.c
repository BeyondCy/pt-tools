
#ifndef UNICODE
#define UNICODE
#endif
#pragma comment(lib, "netapi32.lib")

#include <stdio.h>
#include <windows.h> 
#include <lm.h>

// for AD checks
#include <Iads.h>
#include <Adshlp.h>
#pragma comment(lib, "Activeds.lib")
#pragma comment(lib, "ADSIid.lib")

// for initialize/uninitialize COM library 
#pragma comment(lib, "Ole32.lib")

#include <ctype.h>

static void toUpperCase(char* s);


/*
Cheks if a computer is in a specified domain

Return:
2 - an error has occured
1 - the computer is in a domain, AND the domain name is dname
0 - otherwise
*/
int is_domain(char *dname)  {
	DWORD dwLevel = 102;
	LPWKSTA_INFO_102 pBuf = NULL;
	NET_API_STATUS nStatus;
	DWORD bufSize = MAX_PATH;
	TCHAR domainNameBuf[MAX_PATH] = {0};
	char convBuffer[MAX_PATH];
	int ret = 0;

	// Get WORKGROUP or DOMAIN (if part of one)
	nStatus = NetWkstaGetInfo(NULL /* local machine*/,
		dwLevel,
		(LPBYTE *)&pBuf);
	if (nStatus != NERR_Success) {
		fprintf(stderr, "[-] A system error has occurred in NetWkstaGetInfo: %d\n", nStatus);
		return 2;
	} else {
		ret = wcstombs (convBuffer,  pBuf->wki102_langroup, sizeof(convBuffer));
		if (-1 == ret) {
			fprintf(stderr, "[-]An error has occurred in wcstombs\n");
			return 2;
		}
	}

	// Check if the computer is part of a domain
	GetComputerNameEx(ComputerNameDnsDomain, domainNameBuf, &bufSize);
	if(NULL == *domainNameBuf) {
		// Not part of the domain, print WORKGROUP
		toUpperCase(convBuffer);
		printf("[+] Workgroup:   %s\n", convBuffer);
	} else {
		// The user has a DOMAIN NAME set
		toUpperCase(convBuffer);
		printf("[+] Domain:   %s\n", convBuffer);

		/* 
		Check if he is *actually connected* to the domain by trying to bind an object
		http://stackoverflow.com/questions/13446590/how-to-tell-if-workstation-is-currently-connected-to-a-domain-controller-with-c 
		*/
		IADs *pObject;
		HRESULT hr;

		// Initialize COM
		CoInitialize(NULL);

		hr = ADsGetObject(L"LDAP://rootDSE", IID_IADs, (void**) &pObject);

		if(SUCCEEDED(hr)) {
			printf("[+] AD is available\n");

			// Compare
			if(NULL != strstr(convBuffer, dname)) {
				// user actually connected to a domain containing dname
				printf("[*] Domain match!\n");
				ret = 1;
			}

			// Release the object.
			pObject->Release();
		} else {
			printf("[-] AD is NOT available\n");
		}

		// Uninitialize COM
		CoUninitialize();
	}

	// cleanup
	if (pBuf != NULL) {
		NetApiBufferFree(pBuf);
	}

	return ret;
}

// convert ansi string to uppercase
static void toUpperCase(char* s) {
	while (*s = toupper(*s)) ++s;
} 

int main(int argc, char *argv[])
{
	if (2 != argc) {
		printf("[-] Usage: %s <domain to match>\n", argv[0]);
		return 2;
	} else {
		toUpperCase(argv[1]);
		return is_domain(argv[1]);
	}
}
