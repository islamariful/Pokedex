import UIKit

class PokemonListViewController: UITableViewController, UISearchBarDelegate {
    @IBOutlet var searchBar: UISearchBar!

    var pokemon: [PokemonListResult] = []
    var pokemonsearch = [PokemonListResult] ()
    
    func capitalize(text: String) -> String {
        return text.prefix(1).uppercased() + text.dropFirst()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=151") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            do {
                let entries = try JSONDecoder().decode(PokemonListResults.self, from: data)
                self.pokemon = entries.results
                self.pokemonsearch = self.pokemon
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemonsearch.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonCell", for: indexPath)
        cell.textLabel?.text = capitalize(text: pokemonsearch[indexPath.row].name)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPokemonSegue",
                let destination = segue.destination as? PokemonViewController,
                let index = tableView.indexPathForSelectedRow?.row {
            destination.url = pokemonsearch[index].url
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchBar.text == ""{
        pokemonsearch = pokemon
        tableView.reloadData()
        return
    }
    pokemonsearch.removeAll()
               
           for pokemon in pokemon {
               if pokemon.name.contains(searchText.lowercased()){
                   pokemonsearch.append(pokemon)
                   tableView.reloadData()
               }
           }
           
           tableView.reloadData()
       }
}
