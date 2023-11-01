# <img src="https://multitheftauto.com/mtasa_icon_hq.png" alt="MTA:SA Logo" width="20"> MTA:SA 3D Editor Resource

**Language: [English](README.md) | [Čeština](README-cz.md)**

Welcome to the MTA:SA 3D Object Editor Resource repository! This resource is designed to provide an easy-to-use tool for editing 3D objects within Multi Theft Auto: San Andreas (MTA:SA). Whether you're a seasoned MTA developer or just starting out, this resource aims to simplify the process of editing 3D objects on your MTA server.

## Features

- **Intuitive Interface:** The 3D Object Editor comes with a user-friendly interface that makes editing objects a breeze.
- **Real-time Preview:** See your changes in real-time as you modify the object's properties.
- **Customization:** Adjust object properties such as position, rotation, and scale.
- **Export Options:** Deeply integrate the resource into your server per your liking.

## Installation

1. Download the latest version of the resource from the [Releases](https://github.com/Derbosik/3DEditor/releases) section.
2. Extract the downloaded archive.
3. Place the extracted folder in the `resources` directory of your MTA:SA server.
4. Add the resource to your server's configuration file (`mtaserver.conf`) under the `resources` section:
   
    ```ini
    <resource src="3DEditor" />
5. Restart your MTA:SA server to ensure that the new resource is loaded and available for use.

## Usage

1. Launch your MTA:SA client and join your server.

2. In any script, start by creating an object.

3. Afterwards, call the export with the element
   
    Clientside Example
    ```lua
    function test()
       local obj = createObject(935, 0, 0, 0)
       exports.3DEditor:startEdit(obj)
    end
    addEventHandler("onClientResourceStart", resourceRoot, test)

    ```

    Serverside Example (Make sure to make player the second argument, this defines the editor controller)
    ```lua
    function test(player)
       local obj = createObject(935, 0, 0, 0)
       exports.3DEditor:startEdit(obj, player)
    end
    addCommandHandler("testing", test)

4. Use the editor's interface to create, edit, and manipulate 3D objects in real-time.

5. Once you're satisfied with your creation, use the save button.

6. A server and client event is going to be triggered, this is where you need to check for the (res) and apply your changes.

    You can implement saving to MySQL/SQLite or just manipulate with the values however you please.
    ```lua
    function listener(res, object, cx, cy, cz, rx, ry, rz, sx, sy, sz)
       if res == resource and source == player then
          saveFurniturePosition(player, object, cx, cy, cz, rx, ry, rz, sx, sy, sz)
       end
    end
    addEventHandler("3DEditor:savedObject", root, listener)

## Contributing

Contributions are welcome! If you have ideas for improvements or new features, feel free to create issues or pull requests. Please follow the established coding and contribution guidelines.

## License

This project is licensed under the [GNU General Public License version 3.0](LICENSE).

## Credits

- [Derbosik](https://github.com/Derbosik) & [wavesk](https://github.com/wavesk) - Lead Developers
- [Denas1](https://github.com/Denas1) - Giving ideas for improvements

Special thanks to the MTA community for their support and inspiration.

---

We hope you enjoy using the MTA:SA 3D Object Editor Resource! If you encounter any issues or have questions, please don't hesitate to [open an issue](https://github.com/Derbosik/3DEditor/issues). Happy object editing!
