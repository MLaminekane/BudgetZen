import LocalAuthentication
import SwiftUI

class AuthenticationService: ObservableObject {
    static let shared = AuthenticationService()
    
    @AppStorage("usePIN") private var usePIN = false
    @AppStorage("pinCode") private var storedPIN = ""
    @AppStorage("useDevicePIN") private var useDevicePIN = false
    @AppStorage("useFaceID") private var useFaceID = false
    @Published var isAuthenticated = false
    
    func authenticate() async -> Bool {
        if usePIN {
            if useDevicePIN {
                return await authenticateWithDevicePIN()
            } else if useFaceID {
                return await authenticateWithBiometrics()
            }
            return false // Nécessite saisie manuelle du PIN
        }
        return true
    }
    
    private func authenticateWithDevicePIN() async -> Bool {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            do {
                let success = try await context.evaluatePolicy(
                    .deviceOwnerAuthentication,
                    localizedReason: "Déverrouiller BudgetZen"
                )
                
                await MainActor.run {
                    isAuthenticated = success
                }
                return success
            } catch {
                return false
            }
        }
        return false
    }
    
    private func authenticateWithBiometrics() async -> Bool {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            do {
                let success = try await context.evaluatePolicy(
                    .deviceOwnerAuthenticationWithBiometrics,
                    localizedReason: "Déverrouiller BudgetZen"
                )
                
                await MainActor.run {
                    isAuthenticated = success
                }
                return success
            } catch {
                return false
            }
        }
        return false
    }
    
    func verifyPIN(_ enteredPIN: String) -> Bool {
        if useDevicePIN {
            // Utiliser l'authentification du système
            return authenticateWithDevicePINSync()
        }
        
        let success = enteredPIN == storedPIN
        isAuthenticated = success
        return success
    }
    
    private func authenticateWithDevicePINSync() -> Bool {
        let semaphore = DispatchSemaphore(value: 0)
        var authSuccess = false
        
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthentication,
                             localizedReason: "Déverrouiller BudgetZen") { success, error in
            authSuccess = success
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 30)
        isAuthenticated = authSuccess
        return authSuccess
    }
    
    func requiresAuthentication() -> Bool {
        return usePIN || LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
} 