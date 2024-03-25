import SwiftUI
import NetworkExtension

struct ContentView: View {
    @State var buttonText = "Hello, world!";
	var body: some View {
        Button(action: installBtn) {
            Text(buttonText)
                .padding()
        }
	}

    func makeManager() -> NETunnelProviderManager {
        let manager = NETunnelProviderManager()
        manager.localizedDescription = "Whisper iOS"

        let proto = NETunnelProviderProtocol()
        proto.providerBundleIdentifier = "dev.r58playz.whisper.wispvpn"
        proto.serverAddress = "127.0.0.1:4009"
        proto.providerConfiguration = [:]

        manager.protocolConfiguration = proto

        // Enable the manager by default
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
