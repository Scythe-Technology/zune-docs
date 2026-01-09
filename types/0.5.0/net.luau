--- @name Network
--- @global `zune.net`
--- @summary A library to do networking in luau. Provides functions to create sockets, start an HTTP server, make HTTP requests, and handle WebSockets.

type __0__ = typeof(nil);

--- @class
type NetworkSocket = {
    --- Sends data over the socket, and returns the number of bytes sent.
    --- @param data The data to send.
    --- @param offset The offset to start sending from.
    --- @default_param offset 0
    --- @throws Network Error
    --- @throws Memory Error
    send: (self: NetworkSocket, data: string | buffer, offset: number?) -> number,
    --- Sends data over the socket, and returns the number of bytes sent.
    --- @param port The port to send the message to.
    --- @param address The address to send the message to.
    --- @param data The data to send.
    --- @param offset The offset to start sending from.
    --- @default_param offset 0
    --- @throws Network Error
    --- @throws Memory Error
    sendMsg: (self: NetworkSocket, port: number, address: string, data: string | buffer, offset: number?) -> number,
    --- @param max_size The maximum size of the data to receive.
    --- @default_param max_size 8192
    --- @throws Network Error
    --- @throws Memory Error
    recv: (self: NetworkSocket, max_size: number?) -> buffer,
    --- @param max_size The maximum size of the message to receive.
    --- @default_param max_size 8192
    --- @throws Network Error
    --- @throws Memory Error
    recvMsg: (self: NetworkSocket, max_size: number?) -> (NetworkAddress, buffer),
    --- Yields and waits for a connection to be made on the socket, and returns a `NetworkSocket` object.
    --- @throws IO Error
    accept: (self: NetworkSocket) -> NetworkSocket,
    --- Connects the socket to the specified address and port.
    --- @param address The address to connect to.
    --- @param port The port to connect to.
    --- @throws Network Error
    connect: (self: NetworkSocket, address: string, port: number) -> (),
    --- Starts listening for incoming connections on the socket.
    --- @param backlog The maximum number of connections to backlog.
    --- @default_param backlog 128
    --- @throws IO Error
    listen: (self: NetworkSocket, backlog: number?) -> (),
    --- Binds the socket to the specified address and port.
    --- @param address The address to bind to.
    --- @param port The port to bind to.
    --- @throws Network Error
    bindIp: (self: NetworkSocket, address: string, port: number) -> (),
    --- @throws Network Error
    --- @throws Memory Error
    getName: (self: NetworkSocket) -> NetworkAddress,
    --- Sets a socket option on the socket.
    --- @param level The level of the option.
    --- @param optname The name of the option.
    --- @param value The value of the option.
    --- @throws Network Error
    setOption: (self: NetworkSocket, level: number, optname: number, value: boolean | string | buffer) -> (),
    --- Closes the socket.
    --- @throws IO Error
    --- @throws Network Error
    close: (self: NetworkSocket) -> (),
    --- Returns if the socket is open.
    isOpen: (self: NetworkSocket) -> boolean,
}

--- @class
type HttpServer = {
    --- Stop and kill server.
    stop: (self: HttpServer) -> (),
    --- Returns the port the server is bound to.
    getPort: (self: HttpServer) -> number,
    --- Returns if the server is running.
    isRunning: (self: HttpServer) -> boolean,
}

--- @class
type HttpWebSocket = {
    --- Sends a message to the connected WebSocket.
    --- @param message The message to send.
    --- @throws Memory Error
    --- @throws WebSocket Error
    send: (self: HttpWebSocket, message: string | buffer) -> (),
    --- Closes the WebSocket connection.
    --- @param code The close code to send.
    --- @default_param code 1000
    --- @throws Memory Error
    --- @throws WebSocket Error
    close: (self: HttpWebSocket, code: number?) -> (),
    --- Returns if the WebSocket is connected.
    isConnected: (self: HttpWebSocket) -> boolean,
}

export type NetworkAddress = {
    family: number,
    port: number,
    address: string,
}

export type HttpServerRequest = {
    method: string,
    path: string,
    raw_path: string,
    query: {[string | number]: string},
    headers: {[string]: string},
    body: string?,
}

export type HttpServerResponse = {
    status_code: number,
    headers: {[string]: string}?,
    body: (string | buffer)?,
}

export type ServerWebSocketHandlers = {
    --- The function to call when a WebSocket upgrade request is received.
    --- - If `true` is returned, the upgrade will be accepted.
    --- - If `false` is returned, the upgrade will be rejected.
    upgrade: ((request: HttpServerRequest) -> boolean)?,
    --- The function to call when a WebSocket connection is opened.
    open: ((websocket: HttpWebSocket) -> ())?,
    --- The function to call when a message is received on a WebSocket connection.
    message: ((websocket: HttpWebSocket, message: string) -> ())?,
    --- The function to call when a WebSocket connection is closed.
    close: ((websocket: HttpWebSocket, code: number) -> ())?,
}

export type HttpServeOptions = {
    --- The port to listen on.
    port: number,
    --- The address to bind to.
    --- @default "127.0.0.1"
    address: string?,
    --- Whether to reuse the address.
    --- @default false
    reuse_address: boolean?,
    --- The maximum number of connections the server will backlog to the OS.
    --- @default 128
    backlog: number?,
    --- The maximum size of the request body.
    --- @default 1048576
    max_body_size: number?,
    --- The maximum size of the request headers for the parser.
    --- @default 4092
    max_header_size: number?,
    --- The maximum number of headers to parse from the request.
    --- @default 100
    max_headers: number?,
    --- The timeout for the client.
    --- @default 60
    client_timeout: number?,
    --- The maximum number of connections.
    --- - `0` for no limit
    --- @default 1024
    max_connections: number?,
    --- The function to call when a request is received.
    --- - If a `HttpServerResponse` is returned, it will be sent as the response.
    --- - If a `string` or `buffer` is returned, it will be sent as the response body with a `200 OK` status.
    request: (request: HttpServerRequest) -> string | buffer | HttpServerResponse,
    --- The handlers for WebSocket connections.
    websocket: ServerWebSocketHandlers?,
    --- Tls options for the server.
    tls: {
        auth: TlsCertKeyPair?,
    }?,
}

export type HttpResponse<T> = {
    ok: boolean,
    status_code: number,
    status_reason: string,
    headers: {[string]: string},
    body: T,
}

export type HttpRequestOptions = {
    headers: {[string]: string}?,
    --- @default "GET"
    method: ("GET" | "HEAD" | "POST" | "PUT" | "DELETE" | "CONNECT" | "OPTIONS" | "TRACE" | "PATCH")?,
    body: (string | buffer)?,
    --- @default true
    allow_redirects: boolean?,
    --- The timeout for the request in seconds.
    --- - If the timeout is zero, the request will never timeout.
    --- @default 30
    timeout: number?,
    --- The maximum size of the response body.
    --- @default 1_048_576
    max_body_size: number?,
    --- The maximum size of the response headers for the parser.
    --- @default 4096
    max_header_size: number?,
    --- The maximum number of headers to parse from the response.
    --- @default 100
    max_headers: number?,
    --- Tls options for the request.
    tls: {
        host: string?,
        ca: TlsCertBundle?,
    }?,
}

export type HttpWebSocketOptions = {
    headers: {[string]: string}?,
    --- The protocols to send to the server.
    protocols: {string}?,
    --- The timeout for the WebSocket connection.
    --- - If the timeout is negative, the WebSocket will never timeout.
    --- @default 30
    timeout: number?,
    --- The function to call to accept the WebSocket connection.
    accept: ((socket: HttpWebSocket, request: HttpServerResponse) -> boolean)?,
    --- The function to call when the WebSocket connection is opened.
    open: ((socket: HttpWebSocket) -> ())?,
    --- The function to call when the WebSocket connection is closed.
    close: ((socket: HttpWebSocket, close: number?) -> ())?,
    --- The function to call when a message is received.
    message: ((socket: HttpWebSocket, message: string) -> ())?,
    --- Tls options for the WebSocket connection.
    tls: {
        host: string?,
        ca: TlsCertBundle?,
    }?,
}

--- The table of address families.
type NetworkAddressFamily = {
    RDS: number,
    ROSE: number,
    BRIDGE: number,
    PHONET: number,
    SNA: number,
    FILE: number,
    MPLS: number,
    ROUTE: number,
    WANPIPE: number,
    UNSPEC: number,
    CAIF: number,
    NETROM: number,
    UNIX: number,
    INET: number,
    ATMSVC: number,
    MAX: number,
    NETLINK: number,
    IUCV: number,
    SMC: number,
    INET6: number,
    TIPC: number,
    KEY: number,
    QIPCRTR: number,
    VSOCK: number,
    IPX: number,
    ASH: number,
    IB: number,
    PACKET: number,
    KCM: number,
    DECnet: number,
    RXRPC: number,
    NETBEUI: number,
    NFC: number,
    ALG: number,
    IEEE802154: number,
    ISDN: number,
    XDP: number,
    LOCAL: number,
    BLUETOOTH: number,
    CAN: number,
    LLC: number,
    APPLETALK: number,
    PPPOX: number,
    ATMPVC: number,
    AX25: number,
    ECONET: number,
    IRDA: number,
    SECURITY: number,
    X25: number,
}

--- Table of socket flags.
type NetworkSocketFlags = {
    DCCP: number,
    RAW: number,
    RDM: number,
    DGRAM: number,
    PACKET: number,
    STREAM: number,
    SEQPACKET: number,
    CLOEXEC: number,
    NONBLOCK: number,
}

--- Table of IP protocols.
type NetworkIPProtocols = {
    COMP: number,
    ICMP: number,
    ESP: number,
    IGMP: number,
    TCP: number,
    ICMPV6: number,
    MTP: number,
    GRE: number,
    SCTP: number,
    MAX: number,
    NONE: number,
    FRAGMENT: number,
    IDP: number,
    UDPLITE: number,
    HOPOPTS: number,
    MH: number,
    BEETPH: number,
    AH: number,
    IPIP: number,
    IPV6: number,
    PIM: number,
    DSTOPTS: number,
    UDP: number,
    DCCP: number,
    RAW: number,
    PUP: number,
    MPLS: number,
    ENCAP: number,
    RSVP: number,
    ROUTING: number,
    EGP: number,
    TP: number,
    IP: number,
}

--- Table of socket option levels.
type NetworkSocketOptionLevel = {
    PPPOL2TP: number,
    RDS: number,
    TIPC: number,
    ALG: number,
    PNPIPE: number,
    BLUETOOTH: number,
    PACKET: number,
    IPV6: number,
    KCM: number,
    RXRPC: number,
    NETBEUI: number,
    DECNET: number,
    TLS: number,
    ICMPV6: number,
    RAW: number,
    XDP: number,
    SOCKET: number,
    LLC: number,
    NFC: number,
    CAIF: number,
    IUCV: number,
    X25: number,
    AAL: number,
    NETLINK: number,
    DCCP: number,
    IRDA: number,
    ATM: number,
    IP: number,
}

--- Table of socket options.
type NetworkSocketOption = {
    ATTACH_FILTER: number,
    CNX_ADVICE: number,
    PEERCRED: number,
    LINGER: number,
    DEBUG: number,
    RXQ_OVFL: number,
    SNDBUF: number,
    DONTROUTE: number,
    ZEROCOPY: number,
    PASSCRED: number,
    DETACH_REUSEPORT_BPF: number,
    ATTACH_REUSEPORT_EBPF: number,
    MEMINFO: number,
    COOKIE: number,
    SNDBUFFORCE: number,
    PRIORITY: number,
    BSDCOMPAT: number,
    SNDTIMEO: number,
    BINDTODEVICE: number,
    OOBINLINE: number,
    BPF_EXTENSIONS: number,
    TIMESTAMP_NEW: number,
    NO_CHECK: number,
    WIFI_STATUS: number,
    PEERGROUPS: number,
    TYPE: number,
    NOFCS: number,
    DOMAIN: number,
    TIMESTAMPNS_NEW: number,
    SNDLOWAT: number,
    KEEPALIVE: number,
    PEEK_OFF: number,
    PEERSEC: number,
    PEERNAME: number,
    RCVBUF: number,
    REUSEPORT: number?,
    INCOMING_NAPI_ID: number,
    TIMESTAMPING_OLD: number,
    RCVBUFFORCE: number,
    REUSEADDR: number,
    MAX_PACING_RATE: number,
    MARK: number,
    RCVTIMEO_NEW: number,
    BUSY_POLL: number,
    TIMESTAMPING_NEW: number,
    BINDTOIFINDEX: number,
    TXTIME: number,
    SECURITY_ENCRYPTION_NETWORK: number,
    LOCK_FILTER: number,
    RCVLOWAT: number,
    SECURITY_ENCRYPTION_TRANSPORT: number,
    ATTACH_BPF: number,
    INCOMING_CPU: number,
    ERROR: number,
    SELECT_ERR_QUEUE: number,
    DETACH_BPF: number,
    SNDTIMEO_NEW: number,
    TIMESTAMPNS_OLD: number,
    PASSSEC: number,
    TIMESTAMP_OLD: number,
    GET_FILTER: number,
    DETACH_FILTER: number,
    ATTACH_REUSEPORT_CBPF: number,
    BROADCAST: number,
    SECURITY_AUTHENTICATION: number,
    PROTOCOL: number,
    ACCEPTCONN: number,
    RCVTIMEO: number,
}

type NetworkLib = {
    ADDRF: NetworkAddressFamily,
    SOCKF: NetworkSocketFlags,
    SOCKOPT: NetworkSocketOption,
    SOCKOPTLV: NetworkSocketOptionLevel,
    IPPROTO: NetworkIPProtocols,

    --- Creates a new socket from OS.
    --- @param address_family The address family to use.
    --- @param flags The socket type to use.
    --- @param protocol The protocol to use.
    --- @throws IO Error
    --- @throws Network Error
    createSocket: (address_family: number, flags: number, protocol: number) -> NetworkSocket,
    --- Gets a list of addresses for the provided name and port.
    --- @param name The name to resolve.
    --- @param port The port to resolve.
    --- @throws IO Error
    getAddressList: (name: string, port: number) -> {NetworkAddress},

    http: {
        --- Starts a new HTTP server.
        --- @param opts The options for the server.
        --- @throws IO Error
        --- @throws Network Error
        serve: (opts: HttpServeOptions) -> HttpServer,
        --- Makes a request to the specified host.
        ---
        --- Options are optional, defaults to GET request.
        --- @param host The host to make the request to.
        --- @param opts The options for the request.
        --- @param bytes Whether to return the response body as a buffer or string.
        --- @throws Request Error
        --- @throws Network Error
        request:
            & ((host: string) -> HttpResponse<string>)
            & ((host: string, opts: HttpRequestOptions?, bytes: nil) -> HttpResponse<string>)
            & ((host: string, opts: HttpRequestOptions?, bytes: false) -> HttpResponse<string>)
            & ((host: string, opts: HttpRequestOptions?, bytes: true) -> HttpResponse<buffer>)
            & ((host: string, opts: HttpRequestOptions?, bytes: boolean) -> HttpResponse<string | buffer>),
        -- Creates a new WebSocket connection.
        --- @param host The host to connect to.
        --- @param opts The options for the WebSocket.
        --- @throws WebSocket Error
        --- @throws Network Error
        websocket: (host: string, opts: HttpWebSocketOptions) -> HttpWebSocket,
    }
}

return {} :: NetworkLib;
