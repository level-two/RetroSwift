import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()

    var body: some View {
        ScrollView {
            content()
                .padding(.horizontal, 8)
                .padding(.top, 16)
                .padding(.bottom, 8)
        }
        .alert(isPresented:  Binding { viewModel.error != nil } set: { _ in viewModel.error = nil }) {
            Alert(title: Text("Oops!"), message: Text(viewModel.error ?? ""))
        }
    }

    func content() -> some View {
        VStack(spacing: 32) {
            TextField("Artist name", text: $viewModel.artist)
                .padding()
                .frame(height: 48)
                .cornerRadius(4)
                .overlay { RoundedRectangle(cornerRadius: 4).stroke() }

            Button {
                viewModel.find()
            } label: {
                Text("Find Info")
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
            }
            .buttonStyle(.borderedProminent)

            Toggle("Corrupting app id", isOn: $viewModel.corruptAppId)

            if viewModel.loading {
                ProgressView()
            } else {
                Text(viewModel.details)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
