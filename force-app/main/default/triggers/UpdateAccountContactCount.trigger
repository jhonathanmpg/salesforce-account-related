// Definimos un trigger sobre el objeto Account
// Se ejecutará después de una inserción (after insert) o actualización (after update)
trigger UpdateAccountContactCount on Account (after insert, after update) {

    // Verificamos si ya se está ejecutando otro trigger (para evitar recursividad infinita)
    if (AccountHelper.isTriggerRunning) {
        return; // Si es true, salimos del trigger
    }

    // Marcamos que el trigger está en ejecución
    AccountHelper.isTriggerRunning = true;

    try {
        // Creamos un conjunto para almacenar los IDs de las cuentas modificadas
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : Trigger.new) {
            accountIds.add(acc.Id); // Agregamos cada ID al conjunto
        }

        // Llamamos al método de la clase handler para actualizar los contactos relacionados
        AccountHandler.updateAccountRelatedContact(accountIds);

    } finally {
        // Siempre, al final, marcamos que ya no está corriendo el trigger
        // Esto permite que otros triggers puedan ejecutarse después si es necesario
        AccountHelper.isTriggerRunning = false;
    }
}