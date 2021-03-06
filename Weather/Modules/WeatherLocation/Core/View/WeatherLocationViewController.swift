import UIKit
import ASToast


class WeatherLocationViewController: UIViewController {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var presenter: WeatherLocationPresenter?
    var viewModel: SelectableLocationListViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = UIRectEdge.None
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(cancelAction))
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.keyboardDismissMode = .OnDrag
        
        self.searchBar.delegate = self
        self.spinner.hidesWhenStopped = true
        
        self.presenter?.loadContent()
    }
    
    // MARK: Actions
    
    func cancelAction() {
        self.searchBar.resignFirstResponder()
        self.presenter?.cancelSearchForLocation()
    }
    
    // MARK: Helpers
    
    private func showToastWithText(text: String) {
        self.view.makeToast(text,
                            duration: NSTimeInterval(3.0),
                            position: ASToastPosition.ASToastPositionCenter.rawValue,
                            backgroundColor: nil)
    }
    
}

// MARK: - <WeatherLocationView>
extension WeatherLocationViewController: WeatherLocationView {
    
    func displayLoading() {
        self.searchBar.hidden = false
        self.tableView.hidden = true
        self.spinner.startAnimating()
    }

    func displaySearch() {
        self.searchBar.hidden = false
        self.tableView.hidden = false
        self.spinner.stopAnimating()
        
        self.searchBar.becomeFirstResponder()
    }

    func displayNoResults() {
        self.searchBar.hidden = false
        self.tableView.hidden = false
        self.spinner.stopAnimating()
        
        self.viewModel = nil
        self.tableView.reloadData()
        
        self.showToastWithText("No Results")
    }

    func displayErrorMessage(errorMessage: String) {
        self.searchBar.hidden = false
        self.tableView.hidden = false
        self.spinner.stopAnimating()
        
        self.showToastWithText(errorMessage)
    }

    func displayLocations(viewModel: SelectableLocationListViewModel) {
        self.searchBar.hidden = false
        self.tableView.hidden = false
        self.spinner.stopAnimating()
        
        self.viewModel = viewModel
        self.tableView.reloadData()
    }
    
}

// MARK: - <UISearchBarDelegate>
extension WeatherLocationViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let text = searchBar.text {
            self.presenter?.searchLocation(text)
        }
    }
    
}

// MARK: - <UITableViewDelegate>
extension WeatherLocationViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let location = self.viewModel?.locations[indexPath.row] {
            self.presenter?.selectLocation(location.locationId)
        }
    }
    
}

// MARK: - <UITableViewDataSource>
extension WeatherLocationViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel?.locations.count ?? 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("WeatherLocationCell")
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "WeatherLocationCell")
        }
        
        if let location = self.viewModel?.locations[indexPath.row] {
            cell?.textLabel?.text = location.name
            cell?.detailTextLabel?.text = location.detail
        }
        
        return cell!
    }

}
