// Consultar todas las cuentas existentes
List<Account> allAccounts = [SELECT Id FROM Account];

// Obtener los IDs de las cuentas
Set<Id> accountIds = new Set<Id>();
for (Account acc : allAccounts) {
    accountIds.add(acc.Id);
}

// Actualizar el número de contactos relacionados
AccountHandler.updateAccountRelatedContact(accountIds);
