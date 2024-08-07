import Foundation

struct NetworkClient {
    
    private enum NetworkClient: Error {
        case codeError
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        
        let request = URLRequest(url: url)
        
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            
            if let error = error {
                handler(.failure(error))
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkClient.codeError))
                return
            }
            
            guard let data = data else { return }
            handler(.success(data))
        })
        
        task.resume()
    }
}
