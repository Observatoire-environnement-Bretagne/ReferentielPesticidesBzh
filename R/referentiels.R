#' Liste des référentiels sources
#'
#' Table de description des référentiels sources pour les informations sur les produits et substances pesticides retenus dans le cadre du groupe de travail régional animé par l'Observatoire de l'Environnement en Bretagne.
#'
#' @format Une table de données de 5 lignes et 11 variables :
#' \describe{
#' \item{dataset}{char l'identifiant du jeu de données source : oeb, echa, ephy, agritox, siris, ...}
#' \item{column_name}{char le nom de la colonne dans la table source}
#' \item{variable}{char le nom de l'attribut dans la table résultat}
#' \item{rank}{int L'ordre de sélection des attributs pour la collection des attributs}
#' }
#' @source \url{https://github.com/Observatoire-environnement-Bretagne/ReferentielPesticidesBzh}
"referentiels"