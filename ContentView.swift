import SwiftUI
import NetworkExtension
import Foundation

struct ContentView: View {
    @State var serverAddress = "wss://wisp.mercurywork.shop/";

    @State var success = false

	var body: some View {
    	NavigationView {
        ZStack {
            VStack {
                HStack {
                    Text("Wisp server:")
                    TextField("wss://wisp.mercurywork.shop/", text:$serverAddress)
                        .modifier(FancyInputViewModifier())
                }
                Button(action: installBtn) {
                    Text("Add VPN")
                        .padding()
                        .foregroundColor(success ? .green : .accentColor)
                }
                .background(success ? Color.green.opacity(0.1) : Color.accentColor.opacity(0.1))
                .cornerRadius(12)
                Text("Connect to Whisper via the Settings app.")
                Spacer()
            }.padding()
        }
        .navigationTitle("Whisper")
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
                // TODO: Haptic feedback
                self.success = true
            } catch {
               print("Error: \(error)") // TODO: Alert
            }
            Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
                withAnimation {
                    self.success = false
                }
            }
        }
    }
}
