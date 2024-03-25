import NetworkExtension
import Foundation

class WhisperThread: Thread {
    override func main() {
            NSLog("======================================= CUT BEFORE WHISPER_START");
            let val = whisper_start();
            NSLog("whisper_start() = \(val)");
            NSLog("======================================= CUT AFTER WHISPER_START");
    }
}

class PacketTunnelProvider: NEPacketTunnelProvider {
    override func startTunnel(options: [String : NSObject]? = nil) async throws {
        // get ws from user

        // set mtu in tunnel settings
        let netSettings_preconnect = NEPacketTunnelNetworkSettings.init(tunnelRemoteAddress: "127.0.0.1");
        netSettings_preconnect.mtu = 1500;
        try await self.setTunnelNetworkSettings(netSettings_preconnect)

        // let tunFd = self?.packetFlow.value(forKeyPath: "socket.fileDescriptor") as! Int32
        while self.getTunFd() == nil {
            try await Task.sleep(nanoseconds: 100_000_000);
            NSLog("waiting for packetFlow \(self.getTunFd())");
        }
        let tunFd = self.getTunFd()!;
        NSLog("======================================= CUT BEFORE WHISPER_INIT \(tunFd)");
        // whisper_init(tunFd, ws, mtu);
        whisper_init(tunFd, "wss://anura.pro/", 1500);
        NSLog("======================================= CUT AFTER WHISPER_INIT");

        // let ip = whisper_get_ws_ip();
        let ip = whisper_get_ws_ip();
        let actualIp = String(cString: ip!);
        NSLog("======================================= CUT AFTER WHISPER_GET_WS_IP \(actualIp)");
        // set ip in tunnel settings
        let netSettings = NEPacketTunnelNetworkSettings.init(tunnelRemoteAddress: actualIp);
        netSettings.mtu = 1500;
        NSLog("======================================= CUT BEFORE SET TUNNEL NET SETTINGS 2");
        try await self.setTunnelNetworkSettings(netSettings);
        NSLog("======================================= CUT AFTER SET TUNNEL NET SETTINGS 2");

        // DispatchQueue.global(qos: .default).async { whisper_start() }

        let thread = WhisperThread();
        thread.start();

        NSLog("======================================= CUT BEFORE WHISPER_FREE");
        whisper_free(ip);
        NSLog("======================================= CUT AFTER WHISPER_FREE");
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        NSLog("called stop");
        whisper_stop();
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
                return getsockopt(fd, 2, 2, &buf, &len) == 0 && buf.starts(with: utunPrefix)
            }
        } else {
            return self.packetFlow.value(forKeyPath: "socket.fileDescriptor") as? Int32
        }
    }
}

