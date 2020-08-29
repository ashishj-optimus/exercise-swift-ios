import UIKit

class BloggersViewController: UIViewController {

    var viewModel: BloggersViewModelProtocol = BloggersViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.fetchData()
        // Do any additional setup after loading the view.
    }
}
