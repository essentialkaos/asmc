; INETWORKLISTMANAGER.ASM--
;
; https://devblogs.microsoft.com/oldnewthing/20230112-00/?p=107700
;

include windows.inc
include netlistmgr.inc
include stdio.inc
include tchar.inc

.code

_tmain proc

   .new hr:HRESULT = CoInitializeEx(nullptr, COINIT_MULTITHREADED)

    .if (SUCCEEDED(hr))

        .new IID_INetworkListManager:GUID = _IID_INetworkListManager
        .new CLSID_NetworkListManager:GUID = _CLSID_NetworkListManager
        .new pNetworkListManager:ptr INetworkListManager = NULL
        .new hr:HRESULT = CoCreateInstance(&CLSID_NetworkListManager, NULL,
                CLSCTX_ALL, &IID_INetworkListManager, &pNetworkListManager)

        .if (SUCCEEDED(hr))

           .new IsConnected:BOOL = false
            mov hr,pNetworkListManager.get_IsConnected(&IsConnected)

            .if (SUCCEEDED(hr))
                printf("get_IsConnected(): %#X\n", IsConnected)
            .endif
            mov hr,pNetworkListManager.get_IsConnectedToInternet(&IsConnected)

            .if (SUCCEEDED(hr))
                printf("get_IsConnectedToInternet(): %#X\n", IsConnected)
            .endif

           .new Connectivity:NLM_CONNECTIVITY = NLM_CONNECTIVITY_DISCONNECTED
            mov hr,pNetworkListManager.GetConnectivity(&Connectivity)

            .if (SUCCEEDED(hr))
                printf("GetConnectivity(): %#X\n", Connectivity)

                .if ( Connectivity == NLM_CONNECTIVITY_DISCONNECTED )
                    printf(" NLM_CONNECTIVITY_DISCONNECTED\n")
                .endif
                .if ( Connectivity & NLM_CONNECTIVITY_IPV4_NOTRAFFIC )
                    printf(" NLM_CONNECTIVITY_IPV4_NOTRAFFIC\n")
                .endif
                .if ( Connectivity & NLM_CONNECTIVITY_IPV6_NOTRAFFIC )
                    printf(" NLM_CONNECTIVITY_IPV6_NOTRAFFIC\n")
                .endif
                .if ( Connectivity & NLM_CONNECTIVITY_IPV4_SUBNET )
                    printf(" NLM_CONNECTIVITY_IPV4_SUBNET\n")
                .endif
                .if ( Connectivity & NLM_CONNECTIVITY_IPV4_LOCALNETWORK )
                    printf(" NLM_CONNECTIVITY_IPV4_LOCALNETWORK\n")
                .endif
                .if ( Connectivity & NLM_CONNECTIVITY_IPV4_INTERNET )
                    printf(" NLM_CONNECTIVITY_IPV4_INTERNET\n")
                .endif
                .if ( Connectivity & NLM_CONNECTIVITY_IPV6_SUBNET )
                    printf(" NLM_CONNECTIVITY_IPV6_SUBNET\n")
                .endif
                .if ( Connectivity & NLM_CONNECTIVITY_IPV6_LOCALNETWORK )
                    printf(" NLM_CONNECTIVITY_IPV6_LOCALNETWORK\n")
                .endif
                .if ( Connectivity & NLM_CONNECTIVITY_IPV6_INTERNET )
                    printf(" NLM_CONNECTIVITY_IPV6_INTERNET\n")
                .endif
            .endif
        .else

            ; handle the error somehow

            perror("CoCreateInstance()")
        .endif
        CoUninitialize()
    .endif
    .return(hr)

_tmain endp

    end _tstart
