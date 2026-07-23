Feature: Exemple Gherkin
  En tant que visiteur
  Je veux naviguer sur l'application
  Afin de tester les fonctionnalites

  Background:
    Given je suis sur la page d'accueil

  Scenario: Naviguer vers une section
    When je clique sur "Produits"
    Then je vois la liste des produits

  Scenario: Remplir un formulaire
    Given je suis sur la page de connexion
    When je remplis le champ "email" avec "user@test.com"
    And je remplis le champ "password" avec "secret"
    And je clique sur "Connexion"
    Then je suis connecte

  # Les DataTables permettent de remplir plusieurs champs
  Scenario: Inscription avec DataTable
    When je remplis le formulaire avec:
      | champ    | valeur          |
      | name     | Jean Dupont     |
      | email    | jean@test.com   |
      | password | monMot2Passe    |
    And je valide l'inscription
    Then mon compte est cree
