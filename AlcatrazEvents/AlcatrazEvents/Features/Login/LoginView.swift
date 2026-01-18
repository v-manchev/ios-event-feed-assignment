//
//  LoginView.swift
//  AlcatrazEvents
//
//  Created by Valeri Manchev on 17.01.26.
//

import SwiftUI

private enum LoginConstants {

    enum Text {
        static let title = "Sign In"
        static let emailPlaceholder = "Email"
        static let passwordPlaceholder = "Password"
        static let continueButton = "Continue"

        static let alertTitle = "Sign In Failed"
        static let alertMessage =
            "We couldn’t sign you in. Please check your connection or credentials and try again."
        static let alertButton = "OK"
    }

    enum Spacing {
        static let rootVStack: CGFloat = 24
        static let fieldsVStack: CGFloat = 16
    }

    enum Padding {
        static let fieldVertical: CGFloat = 10
        static let buttonVertical: CGFloat = 14
        static let loadingTop: CGFloat = 8
        static let horizontal: CGFloat = 24
        static let top: CGFloat = 40
    }

    enum CornerRadius {
        static let button: CGFloat = 10
    }

    enum Opacity {
        static let disabledButton: Double = 0.4
    }
}

struct LoginView: View {
    @State private var viewModel = LoginViewModel()
    @EnvironmentObject var appState: AppState

    @State private var showAlert = false

    var body: some View {
        VStack(spacing: LoginConstants.Spacing.rootVStack) {
            titleText
            textFields
            progressView
            button
            Spacer()
        }
        .padding(.horizontal, LoginConstants.Padding.horizontal)
        .padding(.top, LoginConstants.Padding.top)
        .alert(isPresented: $showAlert) {
            alert
        }
    }

    private var titleText: some View {
        Text(LoginConstants.Text.title)
            .font(.title)
            .fontWeight(.semibold)
    }

    private var textFields: some View {
        VStack(spacing: LoginConstants.Spacing.fieldsVStack) {
            TextField(LoginConstants.Text.emailPlaceholder, text: $viewModel.email)
                .textInputAutocapitalization(.none)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                .padding(.vertical, LoginConstants.Padding.fieldVertical)
                .overlay(Divider(), alignment: .bottom)
                .submitLabel(.next)

            SecureField(LoginConstants.Text.passwordPlaceholder, text: $viewModel.password)
                .padding(.vertical, LoginConstants.Padding.fieldVertical)
                .overlay(Divider(), alignment: .bottom)
                .submitLabel(.go)
                .onSubmit {
                    Task { await performLogin() }
                }
        }
    }

    private var progressView: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .padding(.top, LoginConstants.Padding.loadingTop)
            }
        }
    }

    private var button: some View {
        Button(action: submit) {
            Text(LoginConstants.Text.continueButton)
                .frame(maxWidth: .infinity)
                .padding(.vertical, LoginConstants.Padding.buttonVertical)
                .foregroundColor(.white)
                .background(buttonBackground)
                .cornerRadius(LoginConstants.CornerRadius.button)
        }
        .disabled(!viewModel.canSubmit)
    }

    private var buttonBackground: Color {
        viewModel.canSubmit
        ? Color.primary
        : Color.gray.opacity(LoginConstants.Opacity.disabledButton)
    }

    private func submit() {
        Task { await performLogin() }
    }

    private var alert: Alert {
        Alert(
            title: Text(LoginConstants.Text.alertTitle),
            message: Text(LoginConstants.Text.alertMessage),
            dismissButton: .default(Text(LoginConstants.Text.alertButton))
        )
    }

    private func performLogin() async {
        do {
            let user = try await viewModel.login()
            appState.currentUser = user
            appState.isLoggedIn = true
        } catch {
            showAlert = true
        }
    }
}
