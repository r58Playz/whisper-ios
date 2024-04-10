import SwiftUI
import NetworkExtension
import Foundation

struct ContentView: View {
    @State var serverAddress = "wss://wisp.mercurywork.shop/";

    @State var success = false
    @State var inProgress = false

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
                    if inProgress {
                        ProgressView()
                            .padding()
                    }
                    Text("Add VPN")
                        .padding()
                        .foregroundColor(inProgress ? Color(UIColor.secondaryLabel) : (success ? .green : .accentColor))
                }
                .background(inProgress ? Color(UIColor.secondarySystemBackground).opacity(0.1) : (success ? Color.green.opacity(0.1) : Color.accentColor.opacity(0.1)))
                .cornerRadius(12)
                .disabled(inProgress)
                Text("Connect to Whisper via the Settings app.")
                Spacer()
            }.padding()
        }
        .navigationTitle("Whisper")
        }
        .animation(.timingCurve(0.25, 0.1, 0.35, 1.75).speed(1.2), value: inProgress)
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
        inProgress = true
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
        inProgress = false
    }
}
