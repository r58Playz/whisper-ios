import NetworkExtension
import Foundation

class PacketTunnelProvider: NEPacketTunnelProvider {

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        // get ws from user
        // set mtu in tunnel settings
        // let tunFd = self?.packetFlow.value(forKeyPath: "socket.fileDescriptor") as! Int32
        // whisper_init(tunFd, ws, mtu);
        // let ip = whisper_get_ws_ip();
        // set ip in tunnel settings
        // DispatchQueue.global(qos: .default).async { whisper_start() }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // whisper_stop()
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // NOP?
        if let handler = completionHandler {
            handler(messageData)
        }
    }
    
    override func sleep(completionHandler: @escaping () -> Void) {
        // maybe whisper_stop?
        completionHandler()
    }
    
    override func wake() {
        // maybe whisper_init() and whisper_start()?
    }
}

