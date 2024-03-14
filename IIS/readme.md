# Internet Information Services (IIS)

## Green-Blue Switch (lokaalne demo)

Green-blue switch on meetod veebirakenduse uue versiooni avaldamiseks ilma, et saidi töös kasutajate jaoks tõrkeid tekkiks. Selle näite skriptid on mõeldud antud kontseptsiooni demomiseks. Live juhtudel tuleks kasutada load balanceri ning ümbersuunamised teha selle tasemel.

Proovimiseks on vaja:

- Internet Information Services (IIS)
- Blue sait (host headerid: greenblue-live ja live)
- Green sait (host header: greenblue-test)
- skriptid samas masinas

### Failid

- **local-switch-1.ps** - peale uue versiooni paigaldamist greenblue-test peale vahetab see skript avalikud hosti headerid blue pealt green peale
- **local-switch-2.ps** - peale uue versiooni paigaldamist greenblue-live peale vahetab see skript avalikud hosti headerid greeni peale blue peale