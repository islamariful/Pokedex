import UIKit

var pokedex = Pokedex.init(caught:[:])
var saved = UserDefaults.standard

class PokemonViewController: UIViewController {
    var url: String!

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var type1Label: UILabel!
    @IBOutlet var type2Label: UILabel!
    @IBOutlet var catchstatus: UIButton!
    @IBOutlet var Pokesprite: UIImageView!
    @IBOutlet var Pokeinfo: UILabel!
    
    func capitalize(text: String) -> String {
        return text.prefix(1).uppercased() + text.dropFirst()
    }
    @IBAction func togglecatchstatus() {
        
        if pokedex.caught[nameLabel.text!] == false || pokedex.caught[nameLabel.text!] == nil {
            catchstatus.setTitle("Release", for: .normal)
            pokedex.caught[nameLabel.text!] = true
            saved.set(true, forKey: nameLabel.text!)
            
        }
        else {
            catchstatus.setTitle("Catch", for: .normal)
            pokedex.caught[nameLabel.text!] = false
            saved.set(false, forKey: nameLabel.text!)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
        
            loadPokemon()
            loadsprite()
            nameLabel.text = ""
            numberLabel.text = ""
            type1Label.text = ""
            type2Label.text = ""
            Pokeinfo.text = ""
            
    }
    func loadsprite() {
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            guard let data = data else {
                return
            }
            do {
                let result = try JSONDecoder().decode(PokemonSprite.self, from: data)
                DispatchQueue.main.async {
                    let urlSprite = URL(string: result.sprites.front_default)
                    let pokeData = try? Data(contentsOf: urlSprite!)
                    self.Pokesprite.image = UIImage(data: pokeData!)
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }

    func loadPokemon() {
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            guard let data = data else {
                return
            }

            do {
                let result = try JSONDecoder().decode(PokemonResult.self, from: data)
                DispatchQueue.main.async {
                    self.navigationItem.title = self.capitalize(text: result.name)
                    self.nameLabel.text = self.capitalize(text: result.name)
                    self.numberLabel.text = String(format: "#%03d", result.id)
                    
                    
                    let codeddescription = String(format: "https://pokeapi.co/api/v2/pokemon-species/%D/", result.id)
                    guard let description = URL(string: codeddescription) else {
                        return
                    }
                    URLSession.shared.dataTask(with: description) { (data, response, error) in
                      guard let data = data else {
                                      return
                        }
                        
                        do {
                            let pokemondescription = try JSONDecoder().decode(Description.self, from: data)
                            DispatchQueue.main.async {
                                for version in pokemondescription.flavor_text_entries{
                                    self.Pokeinfo.text = version.flavor_text
                                }
                            }
                        }
                        catch let error{
                            print("\(error)")}
                        
                    }.resume()

                    if saved.bool(forKey: self.nameLabel.text!) == true {
                                  
                                  pokedex.caught[self.nameLabel.text!] = true
                        }
                    if pokedex.caught[self.nameLabel.text!] == false || pokedex.caught[self.nameLabel.text!] == nil  {
                            
                        self.catchstatus.setTitle("Catch", for: .normal)
                           
                       }
                    else if pokedex.caught[self.nameLabel.text!] == true {
                            
                        self.catchstatus.setTitle("Release", for: .normal)

                       }
                    
                    for typeEntry in result.types {
                        if typeEntry.slot == 1 {
                            self.type1Label.text = typeEntry.type.name
                            self.type1Label.text = self.capitalize(text: typeEntry.type.name)
                        }
                        else if typeEntry.slot == 2 {
                            self.type2Label.text = typeEntry.type.name
                            self.type2Label.text = self.capitalize(text: typeEntry.type.name)
                        }
                    }
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
        
    }
}
