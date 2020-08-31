import Foundation

protocol Servicable {
    func fetchData<T: Decodable>(for resource: Resource, completion: (Result<[T]?, Error>) -> Void)
}

final class Service: Servicable {
    init() {}
    
    func fetchData<T: Decodable>(for resource: Resource,
                                 completion: (Result<[T]?, Error>) -> Void) {
        let resources = Resource(rawValue: resource.rawValue)
        guard  let data = resources?.data() else { return }
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode([T].self, from: data)
            completion(.success(response))
        } catch (let error) {
            completion(.failure(error))
        }
    }
}
