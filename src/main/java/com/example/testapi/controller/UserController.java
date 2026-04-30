package com.example.testapi.controller;

import com.example.testapi.model.User;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

@RestController
@RequestMapping
public class UserController {

    private final Map<Integer, User> store = new ConcurrentHashMap<>();
    private final AtomicInteger counter = new AtomicInteger(1);

    public UserController() {
        store.put(1, new User(1, "Alice Smith", "alice@example.com"));
        store.put(2, new User(2, "Bob Jones",  "bob@example.com"));
        counter.set(3);
    }

    @GetMapping("/users")
    public List<User> listUsers() {
        return new ArrayList<>(store.values());
    }

    @GetMapping("/users/{id}")
    public ResponseEntity<User> getUser(@PathVariable Integer id) {
        User user = store.get(id);
        return user != null
                ? ResponseEntity.ok(user)
                : ResponseEntity.notFound().build();
    }

    @PostMapping("/users")
    public ResponseEntity<User> createUser(@RequestBody User req) {
        int id = counter.getAndIncrement();
        User user = new User(id, req.getName(), req.getEmail());
        store.put(id, user);
        return ResponseEntity.status(HttpStatus.CREATED).body(user);
    }

    @DeleteMapping("/users/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Integer id) {
        return store.remove(id) != null
                ? ResponseEntity.noContent().build()
                : ResponseEntity.notFound().build();
    }
}
