Audio {
   start = 27,
   loops = {
      { loop = 0, voice = false },
      { loop = 0, voice = true, tbs = 2},
      { loop = 1, voice = false },
      { loop = 1, voice = false },
      { loop = 1, voice = true , tbs = 1.75},
      { loop = 2, voice = false },
      { loop = 2, voice = true , tbs = 1.5},
	  { loop = 3, voice = false },
      { loop = 3, voice = true , tbs = 1.25},
      { loop = 3, voice = false },
      { loop = 3, voice = false },

	  { loop = 4, voice = true , tbs = 1},
	  { loop = 4, voice = false },

	  { loop = 5, voice = true , tbs = 1.25},
	  { loop = 5, voice = false },

	  { loop = 4, voice = false },
	  { loop = 4, voice = true , tbs = 1},
	  { loop = 4, voice = false },

	  { loop = 3, voice = false },
	  { loop = 3, voice = true , tbs = 1},
	  { loop = 3, voice = false },

	  { loop = 2, voice = false },
	  { loop = 2, voice = false },
	  { loop = 2, voice = true , tbs = 0.8},
	  { loop = 2, voice = false },

	  { loop = 1, voice = true , tbs = 0.6},
	  { loop = 1, voice = false },
      { loop = 1, voice = false },
      { loop = 1, voice = false },
   }
}

EnemyBuilding {
   range = 325,
   dps = 1,
   name = "Station Défense 3000",
   text = "Ici bientôt hôtel, bureaux, apparts de standing"
}


EndGame {
       lost = { "Tu as perdu", "le quartier est entièrement gentrifié" }
}

GameplayVariable {
   buildingTreshold = 20,
   initialConcertInfluence = 620,
   concertRange = 450,
   concertDps = 2,
   concertInfluenceRate = 30,
   neutralName = "Habitations précaires",
   friendlyName = "Habitations restaurées",
   text = "Au carrefour des tentacules du grand capital et du pouvoir institutionnel, Nanterre.\
\
Au détour de ses mille chemins, la Maison Daniel Féry. Anciennement MJC, et en Majuscule SVP.\
Repère emblématique de la culture populaire, locale et proximale, et parmi bien d’autres, humble monument du hiphop parisien ; espace de création artistique et de diffusion culturelle ; gymnase et cuisine des jeunes et moins jeunes artistes du coin et de tous les parages ; un morceau d’histoire, une adresse sûre, une âme collective et des souvenirs communs.\
Mais depuis quelques saisons les grues ont pris d’assaut le ciel et le sol. C’est plus du goudron, c’est du foncier.\
L’horizon est sous palissade.\
La nouvelle est tombée, d’ici 2 ans la salle aura été rasée.\
GENTRYFIGHT est une cartographie des possibles, une mise en scène simplifiée de l’idée folle que c’est encore jouable... garder le terrain...\
Jeu réalisé en 48h à l'occasion d'une Urban game jam organisée en février 2018.\
Un infini MERCI aux membres des équipes de la salle Daniel Féry. Merci à celles et ceux qui font briller et rugir cet espace. Pour les 2000 coups de mains, la disponibilité, et le sourire malgré les cernes et les heures supp’. Vous n’imaginez pas la portée de vos mains vertes !!\
 \
Enfin pour terminer, on dirait un détail, et pourtant... Daniel Féry était un jeune militant syndiqué, mort par étouffement avec d'autres manifestants au métro Charonne au cours d’une manifestation en solidarité avec l’Algérie indépendante le 8 Février 1962, qui fut sauvagement réprimée par les forces de police sous l’ordre de Maurice Papon. Il y a quelques jours à peine se commémorait le souvenir de ces disparus.\
\
11 février 2018, la police tue, encore et toujours.",

   textCredits ="Billie Brelok : Lyriciste\
Gwendal Evrard : Graphisme\
Judicaëlle Live-Lun : Graphisme\
Jeremiaah : Beatmaker\
Marc Planard : Programmation\
Thomas Planques : Game design\
Axelle Ziegler : Programmation"

}

Tower {
   name = "Bibliothèque 2.0",
   extraName = {""},
   range = 200,
   dps = 4,
   influence = 50,
   influence_rate = 5,
   color = {200,100,100},
   img = "assets/buildings/BtmG_library.png",
   icon = "assets/UI/Icon_Bibli.png",
   tooltip = "Faible portée, grande puissance",
   text = "Dealer de carburant pour bien se pimper dedans,\
mais pas qu’au « siècle des lumières »\
Nan nan, jveux les 5 continents et les 5 Océans,\
Et sur la même étagère\
\
\"…Le savoir est une arme et je sors toujours armé… \"\
Minister A.M.E.R."
}


Tower {
   name = "Local associatif",
   extraName = {""},
   range = 250,
   dps = 2,
   influence = 100,
   influence_rate = 5,
   color = {200,30,30},
   img = "assets/buildings/BtmG_assos.png",
   icon = "assets/UI/Icon_Assos.png",
   tooltip = "Moyenne portée, moyenne puissance",
   text = "J'officie dans l’unofficiel, jus de ruelle, bout de ficelle\
Dans le soutif ou dans la semelle SARL la parallèle\
Rideau rideau mécano sous le matelas sous le manteau\
Ramène moi prima primo ce qui ne passera pas aux infos"

}

Tower {
   name = "Jardin collectif",
   extraName = {""},
   range = 600,
   dps = 1,
   influence = 200,
   influence_rate = 5,
   color = {0,100,200},
   img = "assets/buildings/BtmG_Garden.png",
   icon = "assets/UI/Icon_Garden.png",
   tooltip = "Longue portée, faible puissance",
   text = "La porte est ouverte\
Le couvert et la main verte\
Les cerises, le jasmin, la soupe de roses et d'orties\
Et big up au jardin Gorki\
\
\"Si on peignait les cons en vert, les commissariat seraient des prairies\"\
Fabe"
}

Enemy {
   life = 160,
   color = {120,120,110},
   speed = 25,
   dps = 13,
   range = 200,
   img = { "assets/enemies/Chara_CRS01.png",
           "assets/enemies/Chara_CRS02.png" }
}

Enemy {
   life = 110,
   color = {120,120,210},
   speed = 45,
   dps = 8,
   range = 175,
      img = {
      "assets/enemies/Chara_Bt01.png",
      "assets/enemies/Chara_Bt02.png",
      "assets/enemies/Chara_Bt01.png"
      }
}

Enemy {
   life = 60,
   color = {120,120,210},
   speed = 75,
   dps = 4,
   range = 200,
      img = {
      "assets/enemies/Chara_Cd01.png",
      "assets/enemies/Chara_Cd02.png",
      "assets/enemies/Chara_Cd03.png",
	  "assets/enemies/Chara_Cd04.png"
      }
}
