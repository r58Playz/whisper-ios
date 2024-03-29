import SwiftUI
import NetworkExtension
import Foundation

struct ContentView: View {
    @State var buttonText = "Add VPN";
    @State var serverAddress = "wss://anura.pro/";
	var body: some View {
        VStack {
            Text("Whisper").font(.title)
            Text("Turn any Wisp server into a VPN")
            Spacer()
            HStack {
                Text("Wisp server:")
                TextField("wss://anura.pro/", text:$serverAddress)
            }
            Button(action: installBtn) {
                Text(buttonText)
                    .padding()
            }
            Text("Connect to Whisper via the Settings app.")
            Spacer()
        }.padding()
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

    func installProfile() async throws {
        let tunnel = makeManager()
        try await tunnel.saveToPreferences()
    }

    func installBtn() {
        Task {
            do {
                try await installProfile();
                self.buttonText = "OK";
            } catch {
                self.buttonText = "Error: \(error)";
            }
            Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in 
                self.buttonText = "Add VPN";
            }
        }
    }
}
