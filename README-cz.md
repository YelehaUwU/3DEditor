# <img src="https://multitheftauto.com/mtasa_icon_hq.png" alt="MTA:SA Logo" width="20"> MTA:SA 3D Editor Resource (pAttach podpora)

**Jazyk: [English](README.md) | [Čeština](README-cz.md)**

Vítejte v repozitáři MTA:SA 3D Editoru! Tento zdrojový kód poskytuje snadno použitelný nástroj pro editaci 3D objektů ve hře Multi Theft Auto: San Andreas (MTA:SA). Ať už jste zkušený vývojář pro MTA nebo teprve začínáte, tento zdrojový kód si klade za cíl zjednodušit proces editace 3D objektů na vašem MTA serveru.

<img src="https://github.com/YelehaUwU/3DEditor/assets/99475875/36ae3e16-e87a-439b-9588-cf0c1a3d1a1c" alt="Showcase" width="350">

## Funkce

- **Intuitivní Rozhraní:** 3D Editor objektů má uživatelsky přívětivé rozhraní, které zjednodušuje editaci objektů.
- **Náhled v Reálném Čase:** V reálném čase vidíte změny, které provádíte na vlastnostech objektu.
- **Přizpůsobení:** Upravte vlastnosti objektu, jako je pozice, rotace a měřítko.
- **Udělal jsem chybu**: Vezměte zpět a znovu proveďte úpravy a ujistěte se, že jste zůstali v souladu s tím, co jste chtěli.
- **Vše podle vašich představ**: Vypněte některé funkce, pokud se vám to hodí.
- **Možnosti Exportu:** Hloubkově integrujte zdrojový kód do svého serveru dle vašich přání.

## Instalace

1. Stáhněte nejnovější verzi zdrojového kódu ze sekce [Releases](https://github.com/YelehaUwU/3DEditor/releases).
2. Rozbalte stažený archiv.
3. Umístěte rozbalenou složku do adresáře `resources` na vašem MTA:SA serveru.
4. Přidejte zdrojový kód do konfiguračního souboru vašeho serveru (`mtaserver.conf`) pod sekci `resources`:

    ```ini
    <resource src="3DEditor" />
    ```
5. Restartujte váš MTA:SA server, aby byl nový zdrojový kód nahrán a dostupný k použití.

## Použití

1. Spusťte MTA:SA klienta a připojte se na váš server.

2. V jakémkoliv skriptu začněte tím, že vytvoříte objekt.

3. Poté zavolejte export s prvkem.

    Příklad na straně klienta
    ```lua
    function test()
       local obj = createObject(935, 0, 0, 0)
       exports.3DEditor:startEdit(obj, [disableMoving, disableRotating, disableScaling])
    end
    addEventHandler("onClientResourceStart", resourceRoot, test);
    ```

    Příklad na straně serveru (Ujistěte se, že vyplníte všechny argumenty, player je hráč který určuje ovladač editoru)
    ```lua
    function test(player)
       local obj = createObject(935, 0, 0, 0)
       exports.3DEditor:startEdit(obj, disableMoving, disableRotating, disableScaling, player)
    end
    addCommandHandler("testing", test)

4. Použijte rozhraní editoru k vytváření, upravování a manipulaci s 3D objekty v reálném čase.

5. Jakmile jste spokojeni se svou tvorbou, použijte tlačítko pro uložení.

6. Bude spuštěna událost na serveru a klientovi, zde je třeba kontrolovat zdroj (res) (a "client" pokud na serveru) a aplikovat změny.

    Můžete implementovat uložení do MySQL/SQLite nebo jednoduše manipulovat s hodnotami dle libosti.
    ```lua
    function listener(res, object, cx, cy, cz, rx, ry, rz, sx, sy, sz)
       if res == resource and source == player then
          saveFurniturePosition(player, object, cx, cy, cz, rx, ry, rz, sx, sy, sz)
       end
    end
    addEventHandler("3DEditor:savedObject", root, listener)

## Přispívání

Příspěvky jsou vítány! Pokud máte nápady na vylepšení nebo nové funkce, neváhejte vytvářet žádosti o začlenění změn nebo opravení problémů (pull requesty). Prosím, dodržujte stanovené kódovací a příspěvkové pravidla.

## Licence

Tento projekt je licencován pod licencí [GNU General Public License verze 3.0](LICENSE).

## Autoři

- [YelehaUwU](https://github.com/YelehaUwU) & [Nando](https://github.com/Fernando-A-Rocha) - Vedoucí vývojáři
- [wavesk](https://github.com/wavesk) & [Denas1](https://github.com/Denas1) - Poskytování nápadů na vylepšení

Speciální poděkování komunitě MTA za jejich podporu a inspiraci.

---

Doufáme, že si užijete používání MTA:SA 3D Editoru! Pokud narazíte na nějaké problémy nebo máte otázky, neváhejte [otevřít požadavku](https://github.com/YelehaUwU/3DEditor/issues). Šťastné editování objektů!
