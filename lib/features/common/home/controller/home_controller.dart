/*TODO final userStreamProvider = StreamProvider.autoDispose<List<User>>((ref) async* {
  final _ = ref.watch(triggerProvider); // watches trigger

  final api = ref.read(apiServiceProvider);
  final users = await api.fetchUsers();

  yield users;  // emits users list into the stream
});*/
//TODO this is for listing the items
// When you yield inside an async* function, you're creating a stream that listeners can subscribe to and receive updates over time.
