public class AccountHandler {
    // Método estático que recibe un conjunto de IDs de cuentas
    public static void updateAccountRelatedContact(Set<Id> accountIds) {

        // Mapa para guardar la cantidad de contactos por cuenta (AccountId -> cantidad)
        Map<Id, Integer> contactCountMap = new Map<Id, Integer>();

        // Consulta agregada para contar los contactos agrupados por AccountId
        for (AggregateResult ar : [
            SELECT AccountId, COUNT(Id) contactCount
            FROM Contact
            WHERE AccountId IN :accountIds
            GROUP BY AccountId
        ]) {
            // Guardamos el resultado en el mapa, convirtiendo los valores al tipo adecuado
            contactCountMap.put(
                (Id) ar.get('AccountId'),
                (Integer) ar.get('contactCount')
            );
        }

        // Lista para guardar las cuentas que se deben actualizar
        List<Account> accountsToUpdate = new List<Account>();
        
        // Recorremos los IDs de cuenta recibidos
        for (Id accId : accountIds) {
            // Obtenemos el conteo desde el mapa, si no hay registros se asigna 0
            Integer cnt = contactCountMap.containsKey(accId) ? contactCountMap.get(accId) : 0;

            // Creamos una instancia de la cuenta con el campo personalizado actualizado
            accountsToUpdate.add(new Account(
                Id = accId,
                Number_of_Contacts__c = cnt
            ));
        }

        // Solo hacemos la actualización si hay cuentas en la lista
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}