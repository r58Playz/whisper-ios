import SwiftUI
import NetworkExtension

struct ContentView: View {
    @State var buttonText = "Add VPN";
    @State var serverAddress = "wss://anura.pro/";
	var body: some View {
        VStack {
            TextField("Server", text:$serverAddress)
            Button(action: installBtn) {
                Text(buttonText)
                    .padding()
            }
        }
	}

    func makeManager() -> NETunnelProviderManager {
        let manager = NETunnelProviderManager()
        manager.localizedDescription = "Whisper (\(serverAddress))"

        let proto = NETunnelProviderProtocol()
        proto.providerBundleIdentifier = "dev.r58playz.whisper.wispvpn"
        proto.serverAddress = serverAddress
        proto.includeAllNetworks = true
        proto.providerConfiguration = [:]

        manager.protocolConfiguration = proto

        manager.isEnabled = true

        return manager
    }

    func installProfile(_ completion: @escaping (Result<Void, Error>) -> Void) {
        let tunnel = makeManager()
        tunnel.saveToPreferences { error in
            if let error = error {
                return completion(.failure(error))
            }

            tunnel.loadFromPreferences { error in
                completion(.success(()))
            }
        }
    }

    func installBtn() {
        installProfile({ res in 
            switch res {
                case .success():
                    buttonText = "OK";
                    break;
                case .failure(let err):
                    buttonText = "Fail \(err)";
                    break;
            }
        })
    }
}
