import Foundation

protocol BloggersViewModelProtocol {
    func fetchData()
}

class BloggersViewModel: BloggersViewModelProtocol {
    private let dispatchGroup = DispatchGroup()
    private let api: Servicable
    private var allComments: [Comment] = []
    private var allPosts: [Post] = []
    private var allUsers: [User] = []
    
    init(api: Servicable = Service()) {
        self.api = api
    }
    
    func fetchData() {
        fetchComments()
        fetchPosts()
        fetchUsers()
        
        dispatchGroup.notify(queue: .main) {
            print(self.allComments)
            print(self.allPosts)
            print(self.allUsers)
        }
    }
    
    private func fetchComments() {
        dispatchGroup.enter()
        api.fetchData(for: .comments) { [weak self] (result: Result<[Comment]?, Error>) in
            self?.dispatchGroup.leave()
            switch result {
            case .success(let model):
                guard let dataModel = model else { return }
                self?.allComments = dataModel
            case .failure(let error):
                // Perform failure handling
                print(error.localizedDescription)
            }
        }
    }
    
    private func fetchPosts() {
        dispatchGroup.enter()
        api.fetchData(for: .posts) { [weak self] (result: Result<[Post]?, Error>) in
            self?.dispatchGroup.leave()
            switch result {
            case .success(let model):
                guard let dataModel = model else { return }
                self?.allPosts = dataModel
            case .failure(let error):
                // Perform failure handling
                print(error.localizedDescription)
            }
        }
    }
    
    private func fetchUsers() {
        dispatchGroup.enter()
        api.fetchData(for: .users) { [weak self] (result: Result<[User]?, Error>) in
            self?.dispatchGroup.leave()
            switch result {
            case .success(let model):
                guard let dataModel = model else { return }
                self?.allUsers = dataModel
            case .failure(let error):
                // Perform failure handling
                print(error.localizedDescription)
            }
        }
    }
}
