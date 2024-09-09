struct SearchBar : View {
    @Bindable var viewModel: YippyViewModel
    
    var body : some View {
        TextField(
            text: $viewModel.searchBarValue,
            prompt: Text("Search")
        ) {
            Image(systemName: "magnifyingglass")
        }
        .textFieldStyle(.roundedBorder)
        .autocorrectionDisabled()
        .onChange(of: viewModel.searchBarValue) { _, _ in
            viewModel.runSearch()
        }
    }
}