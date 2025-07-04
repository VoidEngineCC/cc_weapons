# cc_weapons

A modular weapon system for FiveM servers with an HTML-based UI and Lua backend. Perfect for PvP servers.

## Features

- Interactive HTML UI for weapon selection or management  
- Client-server logic using Lua  
- Lightweight and fully customizable  
- Easy to expand with weapon categories or permissions

## Installation

1. **Download or Clone the Repository**
   ```bash
   git clone https://github.com/VoidEngineCC/cc_weapons.git
   ```

2. **Place the resource**
   Copy the `cc_weapons` folder into your FiveM server's `resources` directory.

3. **Add to `server.cfg`**
   ```cfg
   ensure cc_weapons
   ```

## File Structure

```
cc_weapons/
├── client.lua         # Handles player-side logic
├── server.lua         # Manages server logic
├── fxmanifest.lua     # Resource definition
└── ui.html            # Weapon selection or display UI
```

## Customization

- Modify `ui.html` to change layout, design, or add features like filters.
- Add weapon logic in `client.lua` and access control in `server.lua`.

## License

This project is available under the [MIT License](LICENSE).

## Contributing

Open to improvements and enhancements! Feel free to fork the project, make changes, and submit a pull request.

