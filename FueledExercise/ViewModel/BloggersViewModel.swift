import Foundation

protocol BloggersViewModelProtocol {
    func fetchData()
    var numberOfRows: Int { get }
    func getCellLabelText(for index: Int) -> String
    var delegate: BloggersViewModelDelegate? { get set }
}

protocol BloggersViewModelDelegate: class {
    func didCreateUserModels()
}

class BloggersViewModel: BloggersViewModelProtocol {
    private let dispatchGroup = DispatchGroup()
    private let api: Servicable
    private var allComments: [Comment] = []
    private var allPosts: [Post] = []
    private var allUsers: [User] = []
    private var userModels: [UserData] = []
    private var postsCommentsDictionary: [Int: [Comment]] = [:]
    private var userCommentsDictionary: [Int: [Comment]] = [:]
    weak var delegate: BloggersViewModelDelegate?
    let numberOfRows = 3
    
    init(api: Servicable = Service()) {
        self.api = api
    }
    
    func fetchData() {
        fetchComments()
        fetchPosts()
        fetchUsers()
        
        dispatchGroup.notify(queue: .main) {
            self.createPostCommentsDictionary()
            self.createUserCommentsDictionary()
            self.createUserModel()
        }
    }
    
    func getCellLabelText(for index: Int) -> String {
        guard index < userModels.count else { return "" }
        let user = userModels[index]
        return "\(user.name) - \(user.id), Score: \(user.engagementAverage ?? 0)"
    }
    
    // MARK: - Private methods
    
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
    
    private func createPostCommentsDictionary() {
        for comment in allComments {
            if postsCommentsDictionary[comment.postId] != nil {
                postsCommentsDictionary[comment.postId]?.append(comment)
            } else {
                postsCommentsDictionary[comment.postId] = [comment]
            }
        }
    }
    
    private func createUserCommentsDictionary() {
        for post in allPosts {
            let commentsSpecificToPosts = postsCommentsDictionary[post.id]
            if userCommentsDictionary[post.userId] != nil {
                if let comments = commentsSpecificToPosts {
                    userCommentsDictionary[post.userId]?.append(contentsOf: comments)
                }
            } else {
                userCommentsDictionary[post.userId] = commentsSpecificToPosts
            }
        }
    }
    
    private func createUserModel() {
        for user in allUsers {
            let userPosts = allPosts.filter {$0.userId == user.id }
            let numberOfCommentsOnUserPosts = userCommentsDictionary[user.id]
            
            var averageComments: Double = 0
            if let userPostsComments = numberOfCommentsOnUserPosts {
                averageComments = Double(userPostsComments.count) / Double(userPosts.count)
            }
            
            userModels.append(UserData(id: user.id, name: user.name, engagementAverage: averageComments ))
        }
        userModels = userModels.sorted(by: { $0.engagementAverage ?? 0 > $1.engagementAverage ?? 0 })
        delegate?.didCreateUserModels()
    }
}
