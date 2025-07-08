import SwiftUI

// Main content view
struct UserListView: View {
    
    @StateObject var viewModel = GithubUserViewModel()
    @State private var isLoading = false
    @State private var footerRefreshing: Bool = false
    var loadMoreIndexOffset = 10

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(viewModel.users) { user in
                        NavigationLink(destination: UserDetailView(user: user)) {
                            UserRow(user: user)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .listRowSeparator(.hidden)
                        .onAppear {
                            let itemsCount = viewModel.users.count
                            let index = max(itemsCount - loadMoreIndexOffset, 0)
                            if user.id == viewModel.users[index].id {
                                Task {
                                    await loadMore()
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Github Users")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button(action: {}) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.black)
            })
            .background(Color(UIColor.white))
        }.task {
            await loadMore()
        }
    }
    
    func loadMore() async {
        await viewModel.loadMore()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        UserListView()
    }
}
