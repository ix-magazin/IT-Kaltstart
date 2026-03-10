# IT-Kaltstart
Quellcode zum [zweiten](https://www.heise.de/select/ix/2026/4/2604310184918669115) und [dritten](https://www.heise.de/select/ix/2026/4/2606110541908975546) Teil der Titelstrecke von [Frank Benke](https://www.linkedin.com/in/frank-benke-61743928/) zum Kaltstart der IT nach einem Cyberangriff. Erschienen in [iX 04/2026](https://www.heise.de/select/ix/2026/4/).

# iX-tract - Vorarbeiten
- Der Weg zu einer kaltstartfähigen RZ-Infrastruktur ist lang und beinhaltet intensive Lernprozesse.
- Die Grundlage der Kaltstartfähigkeit bildet die Automatisierung von Deployment und Wartung, um die kaltstartfähige Infrastruktur schnell wieder anzufahren.
- Jede IT-Automatisierung steht auf drei Säulen: dem Inventar für die Assets und ihre Eigenschaften, dem Repository, in dem die Aktionen hinterlegt und gepflegt sind, und der Orchestrierung, die Änderungen auf den Assets ausführt.
- In unserer Umgebung kommen NetBox als Inventar oder Configuration Management Database und GitLab als Repository zum Einsatz, außerdem Ansible fürs Konfigurationsmanagement.

# iX-tract - Umsetzung
- Für einen Kaltstart unabdingbar sind vorbereitete Installationsimages, da die Systeme in der Regel neu installiert werden.
- Neben den System- und Anwendungskonfigurationen gehören weitere Daten unter anderem von VMs, Containern und Appliances ins Repository, deren Sicherung mit einigen Kniffen verbunden ist.
- Nicht zu vernachlässigen sind zusätzliche Ressourcen für den Roll-out nach einem Vor- oder Ausfall. Sie lassen sich während des Betriebs für Tests und Ähnliches nutzen.
- Ein Kaltstart stellt die IT-Abteilung immer vor besondere Herausforderungen. Ein realistischer Zeitplan für den Wiederanlauf gibt hier Sicherheit.
