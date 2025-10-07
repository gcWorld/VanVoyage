/// Base repository interface for CRUD operations.
abstract class Repository<T> {
  /// Finds an entity by its ID
  Future<T?> findById(String id);

  /// Finds all entities
  Future<List<T>> findAll();

  /// Inserts a new entity and returns its ID
  Future<String> insert(T entity);

  /// Updates an existing entity and returns the number of rows affected
  Future<int> update(T entity);

  /// Deletes an entity by ID and returns the number of rows affected
  Future<int> delete(String id);
}
