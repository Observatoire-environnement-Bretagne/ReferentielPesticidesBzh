## code to prepare `substances_actives` dataset goes here

library(dplyr)
library(RefPesticidesBzh)

# Load and format datasets from RefPesticidesBzh package ----

## Load oeb_referentiels_substances_actives (OEB) ----

oeb_path <- system.file("oeb_referentiels_substances_actives/", package = "RefPesticidesBzh")
oeb_referentiels_substances_actives <- RefPesticidesBzh::load_dataset(path=oeb_path, pattern="*.csv", encoding = "UTF-8")

### Format to substances table ----

oeb_substances <- oeb_referentiels_substances_actives$oeb_referentiels_substances_actives %>%
  mutate(mise_a_jour = as.Date(`MaJ`),
         dataset = "oeb")%>% 
  select(
    SA_CodeCAS,
    SA_Libelle,
    SA_PNEC,
    source = `Source`,
    dataset,
    mise_a_jour
  ) 

## Load agritox (ANSES) ----

agritox_path <- system.file("agritox/", package = "RefPesticidesBzh")
agritox <- RefPesticidesBzh::load_dataset(path=agritox_path, pattern="*.csv", encoding = "Latin-1")

agritox$mise_a_jour <- RefPesticidesBzh::metadonnees_dataset('https://www.data.gouv.fr/fr/datasets/base-de-donnees-agritox/')$`Modifiée.le` %>% as.Date("%d %b %Y")

### Format to substances table ----

agritox_substances <- agritox$agritox_identite %>%
  left_join(select(agritox$agritox_ecotoxicite, Numéro.CAS, Valeur.PNEC), by = c("N..CAS" = "Numéro.CAS")) %>%
  tibble::as_tibble() %>%
  mutate(SA_PNEC = as.numeric(`Valeur.PNEC`),
         source = "AGRITOX",
         dataset = "agritox",
         mise_a_jour = agritox$mise_a_jour) %>% 
  select(
    SA_CodeCAS = `N..CAS`,
    SA_Libelle = `NOM.SA`,
    SA_PNEC,
    source,
    dataset,
    mise_a_jour
  )

## Load ephy (ANSES) ----

ephy_path <- system.file("ephy/", package = "RefPesticidesBzh")
ephy <- RefPesticidesBzh::load_dataset(path=ephy_path, pattern="*.csv", encoding = "UTF-8")

ephy$mise_a_jour <- RefPesticidesBzh::metadonnees_dataset('https://www.data.gouv.fr/fr/datasets/donnees-ouvertes-du-catalogue-e-phy-des-produits-phytopharmaceutiques-matieres-fertilisantes-et-supports-de-culture-adjuvants-produits-mixtes-et-melanges/')$`Modifiée.le` %>% as.Date("%d %b %Y")

ephy_substances <- ephy$substance_active_v3_utf8 %>%
  tibble::as_tibble() %>%
  mutate(source = "Données E-Phy - Anses",
         dataset = "ephy",
         mise_a_jour = ephy$mise_a_jour)%>% 
  select(
    SA_CodeCAS = Numero.CAS,
    SA_Libelle = Nom.substance.active,
    SA_Statut = Etat.d.autorisation,
    source,
    dataset,
    mise_a_jour
  )

### Format to substances table ----

## Load SIRIS (INERIS) ----

siris_path <- system.file("siris/siris.xls", package = "RefPesticidesBzh")
siris <- readxl::read_xls(siris_path, skip=5)
names(siris) <- make.names(names(siris))


# Bind substances tables ----

substances_actives_union <- agritox_substances %>%
  dplyr::bind_rows(ephy_substances) %>%
  dplyr::bind_rows(oeb_substances)

# Export .rda dataset to data/

# Format final table

substances_actives <- substances_actives_union %>%
  filter(dataset == 'oeb')

usethis::use_data(substances_actives, overwrite = TRUE)
