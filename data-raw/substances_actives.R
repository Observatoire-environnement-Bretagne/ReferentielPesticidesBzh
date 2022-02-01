## code to prepare `substances_actives` dataset goes here

library(magrittr)
library(RefPesticidesBzh)

oeb_path <- system.file("oeb/", package = "RefPesticidesBzh")
oeb <- RefPesticidesBzh::load_dataset(path=oeb_path, pattern="*.csv", encoding = "UTF-8")

agritox_path <- system.file("agritox/", package = "RefPesticidesBzh")
agritox <- RefPesticidesBzh::load_dataset(path=agritox_path, pattern="*.csv", encoding = "Latin-1")

agritox$mise_a_jour <- RefPesticidesBzh::metadonnees_dataset('https://www.data.gouv.fr/fr/datasets/base-de-donnees-agritox/')$`Modifiée.le` %>% as.Date("%d %b %Y")

agritox_sa <- agritox$agritox_identite %>%
  left_join(select(agritox$agritox_ecotoxicite, Numéro.CAS, Valeur.PNEC), by = c("N..CAS" = "Numéro.CAS")) %>%
  as.tibble() %>% 
  select(
    SA_CodeCAS = N..CAS,
    SA_Libelle = NOM.SA,
    SA_PNEC = Valeur.PNEC
  )%>%
  mutate(source = "AGRITOX",
         mise_a_jour = agritox$mise_a_jour)

ephy_path <- system.file("ephy/", package = "RefPesticidesBzh")
ephy <- RefPesticidesBzh::load_dataset(path=ephy_path, pattern="*.csv", encoding = "UTF-8")

ephy$mise_a_jour <- RefPesticidesBzh::metadonnees_dataset('https://www.data.gouv.fr/fr/datasets/donnees-ouvertes-du-catalogue-e-phy-des-produits-phytopharmaceutiques-matieres-fertilisantes-et-supports-de-culture-adjuvants-produits-mixtes-et-melanges/')$`Modifiée.le` %>% as.Date("%d %b %Y")

ephy_sa <- ephy$substance_active_v3_utf8 %>%
  as.tibble() %>% 
  select(
    SA_CodeCAS = Numero.CAS,
    SA_Libelle = Nom.substance.active,
    SA_Statut = Etat.d.autorisation
  )%>%
  mutate(source = "EPHY",
         mise_a_jour = ephy$mise_a_jour)

siris_path <- system.file("siris/siris.xls", package = "RefPesticidesBzh")
siris <- readxl::read_xls(siris_path, skip=5)
names(siris_raw) <- make.names(names(siris_raw))

substances_actives <- agritox_sa %>%
  bind_rows(ephy_sa)

usethis::use_data(substances_actives, overwrite = TRUE)