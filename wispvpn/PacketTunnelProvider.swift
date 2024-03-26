import NetworkExtension
import Foundation

enum WhisperError: Error {
    case failedToGetConfig
    case failedToInit
    case failedToGetTunFd
    case failedToGetWsIp
    case rustFailedWithSomeError
}

class WhisperThread: Thread {
    var tunnel: PacketTunnelProvider
    init(tunnel: PacketTunnelProvider) {
        self.tunnel = tunnel
    }
    override func main() {
        NSLog("======================================= CUT BEFORE WHISPER_START");
        let val = whisper_start();
        NSLog("whisper_start() = \(val ? "was ok!" : "failed with some error")");
        NSLog("======================================= CUT AFTER WHISPER_START");
        if (!val) {
            tunnel.cancelTunnelWithError(WhisperError.rustFailedWithSomeError)
        }
    }
}

class PacketTunnelProvider: NEPacketTunnelProvider {
    override func startTunnel(options: [String : NSObject]? = nil) async throws {
        // get ws from user
        guard let proto = protocolConfiguration as? NETunnelProviderProtocol else {
            throw WhisperError.failedToGetConfig
        }
        NSLog("protocolConfiguration \(proto)")

        // set mtu in tunnel settings
        let netSettings_preconnect = NEPacketTunnelNetworkSettings.init(tunnelRemoteAddress: "127.0.0.1");
        netSettings_preconnect.mtu = 1500;
        try await self.setTunnelNetworkSettings(netSettings_preconnect)

        // let tunFd = self?.packetFlow.value(forKeyPath: "socket.fileDescriptor") as! Int32
        guard let tunFd = self.getTunFd() else {
            NSLog("getTunFd failed");
            throw WhisperError.failedToGetTunFd
        }
        NSLog("======================================= CUT BEFORE WHISPER_INIT \(tunFd)");
        // whisper_init(tunFd, ws, mtu);
        if (!whisper_init(tunFd, protocolConfiguration.serverAddress, 1500)) {
            NSLog("whisper_init failed");
            throw WhisperError.failedToInit
        }
        NSLog("======================================= CUT AFTER WHISPER_INIT");

        // let ip = whisper_get_ws_ip();
        guard let ip = whisper_get_ws_ip() else {
            NSLog("whisper_get_ws_ip failed");
            throw WhisperError.failedToGetWsIp
        }
        let actualIp = String(cString: ip);
        NSLog("======================================= CUT AFTER WHISPER_GET_WS_IP: ip = \(actualIp)");
        NSLog("======================================= CUT BEFORE SET TUNNEL NET SETTINGS 2");
        try await self.setTunnelNetworkSettings(createTunnelSettings(ip: actualIp));
        NSLog("======================================= CUT AFTER SET TUNNEL NET SETTINGS 2");

        // DispatchQueue.global(qos: .default).async { whisper_start() }

        let thread = WhisperThread(tunnel: self);
        // surely 16M will be enough :clueless:
        thread.stackSize = 4096 * 4096;
        thread.start();

        NSLog("======================================= CUT BEFORE WHISPER_FREE");
        whisper_free(ip);
        NSLog("======================================= CUT AFTER WHISPER_FREE");
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        NSLog("called stop");
        if (!whisper_stop()) {
            NSLog("FAILED TO STOP??");
        }
        NSLog("done");
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        NSLog("recieved data: \(messageData)");
        if let handler = completionHandler {
            handler(messageData)
        }
    }
    
    override func sleep(completionHandler: @escaping () -> Void) {
        NSLog("called sleep")
        // maybe whisper_stop?
        completionHandler()
    }
    
    override func wake() {
        NSLog("called wake")
        // maybe whisper_init() and whisper_start()?
    }

    // iii love github search!!
    func getTunFd() -> Int32? {
        if #available(iOS 15, *) {
            var buf = [CChar](repeating: 0, count: Int(IFNAMSIZ))
            let utunPrefix = "utun".utf8CString.dropLast()
            return (0...1024).first { (_ fd: Int32) -> Bool in
                var len = socklen_t(buf.count)
                let ok = getsockopt(fd, 2, 2, &buf, &len) == 0 && buf.starts(with: utunPrefix)
                NSLog("bruteforcing \(ok), \(String(cString:buf))");
                return ok
            }
        } else {
            return self.packetFlow.value(forKeyPath: "socket.fileDescriptor") as? Int32
        }
    }
    func createTunnelSettings(ip: String) -> NEPacketTunnelNetworkSettings  {
        let newSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: ip)
        newSettings.ipv4Settings = NEIPv4Settings(addresses: ["240.0.0.1"], subnetMasks: ["255.255.255.0"])
        newSettings.ipv4Settings?.includedRoutes = [NEIPv4Route.`default`()]
        // newSettings.ipv6Settings?.includedRoutes = [NEIPv6Route.`default`()]
        newSettings.proxySettings = nil
        newSettings.dnsSettings = NEDNSSettings(servers: ["8.8.8.8", "8.8.4.4"])
        newSettings.mtu = 1500
        return newSettings
    }
}

