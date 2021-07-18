//
//  MainTableViewController.swift
//  testTableViewAppMyPlaces
//
//  Created by Алексей Черанёв on 13.07.2021.
//

import UIKit
import RealmSwift
class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var filteredPlaces: Results<Place>!
    private var places: Results<Place>!
    private var ascendingSorting = true
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else {
            return false
        }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var reverseSortingButtonItem: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        places = realm.objects(Place.self)
        
        // Setup the search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    // MARK: Table view delegate
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let place = places[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering
        {
            return filteredPlaces.count
        }
        return places.isEmpty ? 0 : places.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell

        var place = Place()
        
        if isFiltering
        {
            place = filteredPlaces[indexPath.row]
        }
        else
        {
            place = places[indexPath.row]
        }
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.height / 2
        cell.imageOfPlace.clipsToBounds = true
        return cell
    }

    @IBAction func unwindSegue(_ segue: UIStoryboardSegue)
    {
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        newPlaceVC.savePlace()
        tableView.reloadData()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail"
        {
            guard let indexPath = tableView.indexPathForSelectedRow else {
                return
            }
            let place: Place
            if isFiltering
            {
                place = filteredPlaces[indexPath.row]
            }
            else
            {
                place = places[indexPath.row]
            }
            let dvc = segue.destination as! NewPlaceViewController
            dvc.currentPlace = place
        }
    }
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        sort()
        tableView.reloadData()
    }
    @IBAction func reverseSorting(_ sender: UIBarButtonItem) {
        ascendingSorting.toggle()
        
        if ascendingSorting
        {
            reverseSortingButtonItem.image = #imageLiteral(resourceName: "AZ")
        }
        else
        {
            reverseSortingButtonItem.image = #imageLiteral(resourceName: "ZA")
        }
        sort()
        tableView.reloadData()
    }
    
    private func sort()
    {
        if segmentedControl.selectedSegmentIndex == 0
        {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        }
        else if segmentedControl.selectedSegmentIndex == 1
        {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
    }
    
    
}

extension MainViewController: UISearchResultsUpdating
{
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        
        tableView.reloadData()
    }
}
