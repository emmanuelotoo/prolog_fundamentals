/* ===========================================================
   Lesson 7: Constraint Logic Programming (CLP)
   Ertel Ch. 5, Section 5.7
   ===========================================================

   CLP extends Prolog with constraint solvers. Instead of
   generating values and testing them (generate-and-test),
   CLP propagates constraints to reduce the search space
   BEFORE trying concrete values.

   Eugene Freuder: "Constraint programming represents one of the
   closest approaches computer science has yet made to the Holy Grail
   of programming: the user states the problem, the computer solves it."

   SWI-Prolog provides library(clpfd) for finite domain constraints.
   NOTE: Ertel's book uses GNU-Prolog syntax (fd_domain, fd_all_different).
   The SWI-Prolog equivalents are shown below.

   GNU-Prolog                SWI-Prolog (clpfd)
   --------------------------------------------------
   fd_domain(Vs, Lo, Hi)     Vs ins Lo..Hi
   fd_all_different(Vs)      all_different(Vs)
   fd_labeling(Vs)           label(Vs)
   X #= Y                    X #= Y   (same)
   X #\= Y                   X #\= Y  (same)
   dist(X,Y) #>= 2           abs(X-Y) #>= 2

   EXAM: Know how to declare domains, state constraints, and label.

   =========================================================== */

:- use_module(library(clpfd)).


% ===========================================================
% PART 1: Basic CLP Concepts
% ===========================================================
% Step 1: Declare variable domains   (Vars ins Low..High)
% Step 2: State constraints           (#=, #\=, #<, #>, all_different)
% Step 3: Label (search for solutions) (label(Vars))
%
% Propagation happens automatically between steps 2 and 3.
% The solver narrows domains as much as possible before labeling.

% Simple example: find X and Y such that X + Y = 10, X > Y, both in 1..9
simple_example(X, Y) :-
    [X, Y] ins 1..9,
    X + Y #= 10,
    X #> Y,
    label([X, Y]).

% ?- simple_example(X, Y).
% X = 6, Y = 4 ;
% X = 7, Y = 3 ;
% X = 8, Y = 2 ;
% X = 9, Y = 1


% ===========================================================
% PART 2: Room Scheduling (Ertel Example 5.2 / Fig. 5.5)
% ===========================================================
% Four teachers: Mayer, Hoover, Miller, Smith
% Four subjects: German, English, Math, Physics
% Four rooms: 1, 2, 3, 4
% Each teacher teaches exactly one subject in exactly one room.
%
% Constraints:
%   1. Mayer never tests in room 4.
%   2. Miller always tests German.
%   3. Smith and Miller do not give tests in neighboring rooms.
%   4. Hoover tests Mathematics.
%   5. Physics is always tested in room 4.
%   6. German and English are not tested in room 1.

room_schedule :-
    % Teachers -> room numbers
    [Mayer, Hoover, Miller, Smith] ins 1..4,
    all_different([Mayer, Hoover, Miller, Smith]),

    % Subjects -> room numbers
    [German, English, Math, Physics] ins 1..4,
    all_different([German, English, Math, Physics]),

    % Constraints
    Mayer #\= 4,                   % 1. Mayer not in room 4
    Miller #= German,              % 2. Miller tests German
    abs(Miller - Smith) #>= 2,     % 3. Miller and Smith not neighbors
    Hoover #= Math,                % 4. Hoover tests Math
    Physics #= 4,                  % 5. Physics in room 4
    German #\= 1,                  % 6. German not in room 1
    English #\= 1,                 % 6. English not in room 1

    % Label — find concrete values
    label([Mayer, Hoover, Miller, Smith]),

    % Output
    nl,
    write('Room:    1        2        3        4'), nl,
    format('Teacher: ~w~t~30|~w~t~39|~w~t~48|~w~n',
           [Mayer, Hoover, Miller, Smith]),
    write('Teachers: '), write([Mayer, Hoover, Miller, Smith]), nl,
    write('Subjects: '), write([German, English, Math, Physics]), nl.

% ?- room_schedule.
% Teachers: [3, 1, 2, 4]    (Mayer=room3, Hoover=room1, Miller=room2, Smith=room4)
% Subjects: [2, 3, 1, 4]    (German=room2, English=room3, Math=room1, Physics=room4)
%
% Room 1: Hoover, Math
% Room 2: Miller, German
% Room 3: Mayer, English
% Room 4: Smith, Physics


% ===========================================================
% PART 3: SEND + MORE = MONEY
% ===========================================================
% Classic crypto-arithmetic puzzle. Each letter is a distinct digit 0-9.
% S and M cannot be 0 (leading zeros).

send_more_money([S,E,N,D,M,O,R,Y]) :-
    Vars = [S,E,N,D,M,O,R,Y],
    Vars ins 0..9,
    all_different(Vars),
    S #\= 0,
    M #\= 0,
                 S*1000 + E*100 + N*10 + D
    +            M*1000 + O*100 + R*10 + E
    #= M*10000 + O*1000 + N*100 + E*10 + Y,
    label(Vars).

% ?- send_more_money(X).
% X = [9, 5, 6, 7, 1, 0, 8, 2]
% i.e., 9567 + 1085 = 10652


% ===========================================================
% PART 4: N-Queens (4-Queens as intro)
% ===========================================================
% Place N queens on an NxN board so no two attack each other.

queens(N, Queens) :-
    length(Queens, N),
    Queens ins 1..N,
    all_different(Queens),          % no two in same row
    no_diagonal_attacks(Queens),
    label(Queens).

no_diagonal_attacks([]).
no_diagonal_attacks([Q|Qs]) :-
    no_attack(Q, Qs, 1),
    no_diagonal_attacks(Qs).

no_attack(_, [], _).
no_attack(Q, [Q1|Qs], D) :-
    abs(Q - Q1) #\= D,             % diagonal distance != column distance
    D1 is D + 1,
    no_attack(Q, Qs, D1).

% ?- queens(4, Q).
% Q = [2, 4, 1, 3] ;
% Q = [3, 1, 4, 2]

% ?- queens(8, Q).  --> 92 solutions total


% ===========================================================
% PART 5: Einstein's Zebra Puzzle (Ertel Ex 5.9)
% ===========================================================
% Five houses in a row, numbered 1-5 (left to right).
% Each house has: color, nationality, drink, cigarette, pet.
% All different within each category.
%
% Hints:
%  1. The Briton lives in the red house.
%  2. The Swede has a dog.
%  3. The Dane drinks tea.
%  4. The green house is immediately to the left of the white house.
%  5. The owner of the green house drinks coffee.
%  6. The person who smokes Pall Mall has a bird.
%  7. The man in the middle house drinks milk.
%  8. The owner of the yellow house smokes Dunhill.
%  9. The Norwegian lives in the first house.
% 10. The Marlboro smoker lives next to the one who has a cat.
% 11. The man with the horse lives next to the one who smokes Dunhill.
% 12. The Winfield smoker drinks beer.
% 13. The Norwegian lives next to the blue house.
% 14. The German smokes Rothmanns.
% 15. The Marlboro smoker has a neighbor who drinks water.
%
% Question: Who owns the fish?

next_to(X, Y) :- abs(X - Y) #= 1.

einstein(FishOwner) :-
    % Each variable represents the HOUSE NUMBER (1-5) of that attribute.

    % Nationalities
    [Briton, Swede, Dane, Norwegian, German] ins 1..5,
    all_different([Briton, Swede, Dane, Norwegian, German]),

    % Colors
    [Red, Green, Blue, Yellow, White] ins 1..5,
    all_different([Red, Green, Blue, Yellow, White]),

    % Drinks
    [Tea, Coffee, Milk, Beer, Water] ins 1..5,
    all_different([Tea, Coffee, Milk, Beer, Water]),

    % Cigarettes
    [PallMall, Dunhill, Marlboro, Winfield, Rothmanns] ins 1..5,
    all_different([PallMall, Dunhill, Marlboro, Winfield, Rothmanns]),

    % Pets
    [Dog, Bird, Cat, Horse, Fish] ins 1..5,
    all_different([Dog, Bird, Cat, Horse, Fish]),

    % Constraints (hints)
    Briton    #= Red,          %  1
    Swede     #= Dog,          %  2
    Dane      #= Tea,          %  3
    Green + 1 #= White,        %  4  green is left of white
    Green     #= Coffee,       %  5
    PallMall  #= Bird,         %  6
    Milk      #= 3,            %  7  middle house
    Yellow    #= Dunhill,      %  8
    Norwegian #= 1,            %  9  first house
    next_to(Marlboro, Cat),    % 10
    next_to(Horse, Dunhill),   % 11
    Winfield  #= Beer,         % 12
    next_to(Norwegian, Blue),  % 13
    German    #= Rothmanns,    % 14
    next_to(Marlboro, Water),  % 15

    % Label all variables
    label([Briton, Swede, Dane, Norwegian, German,
           Red, Green, Blue, Yellow, White,
           Tea, Coffee, Milk, Beer, Water,
           PallMall, Dunhill, Marlboro, Winfield, Rothmanns,
           Dog, Bird, Cat, Horse, Fish]),

    % Determine who owns the fish
    ( Fish #= Briton    -> FishOwner = briton
    ; Fish #= Swede     -> FishOwner = swede
    ; Fish #= Dane      -> FishOwner = dane
    ; Fish #= Norwegian -> FishOwner = norwegian
    ; Fish #= German    -> FishOwner = german
    ).

% ?- einstein(X).
% X = german
%
% The German owns the fish!

% Full solution:
%   House 1: Yellow, Norwegian, Water,  Dunhill,   Cat
%   House 2: Blue,   Dane,      Tea,    Marlboro,  Horse
%   House 3: Red,    Briton,    Milk,   Pall Mall, Bird
%   House 4: Green,  German,    Coffee, Rothmanns, Fish
%   House 5: White,  Swede,     Beer,   Winfield,  Dog


% ===========================================================
% EXERCISES
% ===========================================================

% Exercise 7.1: Solve the room scheduling problem by hand first,
% then verify with ?- room_schedule.

% Exercise 7.2: Write a CLP solver for a 4x4 Sudoku.
% A 4x4 grid with 2x2 boxes. Fill with digits 1-4, each appearing
% once per row, column, and box.

% Your code here:
% sudoku4x4([R1C1, R1C2, R1C3, R1C4,
%             R2C1, R2C2, R2C3, R2C4,
%             R3C1, R3C2, R3C3, R3C4,
%             R4C1, R4C2, R4C3, R4C4]) :- ...


% Exercise 7.3: Compare the runtime of a generate-and-test approach
% vs CLP for the SEND+MORE=MONEY puzzle. For generate-and-test,
% use permutation/2 to generate all assignments, then test the equation.
% How many times slower is it?


% === SOLUTIONS BELOW — try the exercises first! =========================

% Solution 7.2:
sudoku4x4(Rows) :-
    Rows = [R1C1, R1C2, R1C3, R1C4,
            R2C1, R2C2, R2C3, R2C4,
            R3C1, R3C2, R3C3, R3C4,
            R4C1, R4C2, R4C3, R4C4],
    Rows ins 1..4,

    % Row constraints
    all_different([R1C1, R1C2, R1C3, R1C4]),
    all_different([R2C1, R2C2, R2C3, R2C4]),
    all_different([R3C1, R3C2, R3C3, R3C4]),
    all_different([R4C1, R4C2, R4C3, R4C4]),

    % Column constraints
    all_different([R1C1, R2C1, R3C1, R4C1]),
    all_different([R1C2, R2C2, R3C2, R4C2]),
    all_different([R1C3, R2C3, R3C3, R4C3]),
    all_different([R1C4, R2C4, R3C4, R4C4]),

    % Box constraints (2x2)
    all_different([R1C1, R1C2, R2C1, R2C2]),
    all_different([R1C3, R1C4, R2C3, R2C4]),
    all_different([R3C1, R3C2, R4C1, R4C2]),
    all_different([R3C3, R3C4, R4C3, R4C4]),

    label(Rows).

% Example usage with some cells pre-filled:
% ?- sudoku4x4([1,_,_,_, _,_,3,_, _,3,_,_, _,_,_,2]).

% Solution 7.3:
% Generate-and-test for SEND+MORE=MONEY:
send_more_money_slow([S,E,N,D,M,O,R,Y]) :-
    permutation([0,1,2,3,4,5,6,7,8,9], Perm),
    [S,E,N,D,M,O,R,Y|_] = Perm,
    S \= 0,
    M \= 0,
    V1 is S*1000 + E*100 + N*10 + D,
    V2 is M*1000 + O*100 + R*10 + E,
    V3 is M*10000 + O*1000 + N*100 + E*10 + Y,
    V1 + V2 =:= V3.

% ?- time(send_more_money(X)).        --> very fast, ~few hundred inferences
% ?- time(send_more_money_slow(X)).   --> millions of inferences (try it!)
% CLP prunes the search space via propagation; generate-and-test is brute force.
