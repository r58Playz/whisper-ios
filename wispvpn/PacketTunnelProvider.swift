import NetworkExtension
import Foundation

class PacketTunnelProvider: NEPacketTunnelProvider {
    override func startTunnel(options: [String : NSObject]? = nil) async throws {
        // get ws from user

        // set mtu in tunnel settings
        let netSettings_preconnect = NEPacketTunnelNetworkSettings.init(tunnelRemoteAddress: "127.0.0.1");
        netSettings_preconnect.mtu = 1500;
        try await self.setTunnelNetworkSettings(netSettings_preconnect)

        // let tunFd = self?.packetFlow.value(forKeyPath: "socket.fileDescriptor") as! Int32
        let tunFd = self.packetFlow.value(forKeyPath: "socket.fileDescriptor") as! Int32;
        // whisper_init(tunFd, ws, mtu);
        whisper_init(tunFd, "wss://anura.pro/", 1500);

        // let ip = whisper_get_ws_ip();
        let ip = whisper_get_ws_ip();
        // set ip in tunnel settings
        let netSettings = NEPacketTunnelNetworkSettings.init(tunnelRemoteAddress: String(cString: ip!));
        netSettings.mtu = 1500;
        try await self.setTunnelNetworkSettings(netSettings)

        // DispatchQueue.global(qos: .default).async { whisper_start() }
        DispatchQueue.global(qos: .default).async {
            whisper_start();
        }

        whisper_free(ip);
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
}

