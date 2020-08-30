import UIKit

class BloggersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var viewModel: BloggersViewModelProtocol = BloggersViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        viewModel.fetchData()
    }
}

extension BloggersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BloggersTableViewCell", for: indexPath)
        let text = viewModel.getCellLabelText(for: indexPath.row)
        cell.textLabel?.text = text
        return cell
    }
}

extension BloggersViewController: BloggersViewModelDelegate {
    func didCreateUserModels() {
        tableView.reloadData()
    }
}
