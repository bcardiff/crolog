male(john).
male(andy).
female(mary).

child_of(joe, ralf).
child_of(mary, joe).
child_of(steve, joe).
child_of(steve, ralf).

sibling(X, Y) :- child_of(P, X), child_of(P, Y), X \= Y.

human(X) :- male(X).
human(X) :- female(X).
