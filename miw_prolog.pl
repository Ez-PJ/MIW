/* AUTHOR: Patryk Kamiński s18610 */


/* ------------------------------------------------------------------------------------------------------------------------------------------------------ */
/* ---VARIABLES AND TERMS--- */
% Rooms (current position, position description):
room(bedroom,
     ' You are in your bedroom. There is a door in front of you.').
room(corridor,
     ' You stay in the Corridor. You look around carefully, but there is nothing suspicious here.
       Those sounds are coming from your closed bathroom in front of you! Better not go there unarmed...').
room(wardrobe,
     ' You are in wardrobe. A perfect place for hiding in horror movies.
       You can hear scratching of the claws coming from behind the wall separating the bathroon and the wardrobe').
room(bathroom,
     ' You stepped inside the bathroom. The walls and the ceiling are covered in blood.
       There is a hooded creature standing next to you. Creature screams and lunges at you!').
room(mainHallway, 
     ' You are in the main hallway. There is nothing unusual happening here.').
room(diningRoom,
     ' You are in the dining room ').
room(livingRoom,
     ' You are in the living room. It is not good time to netflix and chill now!').
room(garden,
     ' You are in the garden, outside your house.').

% Paths (current position, next position, direction):
path(bedroom, corridor, north).
path(corridor, bedroom, south).
path(corridor, wardrobe, west).
path(wardrobe, corridor, east).
path(corridor, bathroom, north).
path(bathroom, corridor, south).
path(corridor, mainHallway, downstairs).
path(mainHallway, corridor, upstairs).
path(mainHallway, garden, east).
path(garden, mainHallway, west).
path(mainHallway, diningRoom, west).
path(diningRoom, mainHallway, east).
path(diningRoom, livingRoom, south).
path(livingRoom, diningRoom, north).

% Descriptions (room, room description):
description(bedroom, 
            ' You look around for something useful... Nothing in this room will protect you').
description(corridor, 
            ' There is a wardrobe left to you. In front of you is a mysterious bathroom door. There are stairs to the ground floor nearby.').
description(wardrobe, 
            ' You find a safe hidden in the closet. There is a pistol with ammunition inside.').
description(mainHallway, 
            ' You can still hear those sounds coming from the floor above. Better get out of there!
              You can see dining room on the left and the exit door to the garden on the right. There are stairs to the ground floor nearby').
description(diningRoom,
            ' You can see big dining table in the middle of the room. There are house keys laying on it. Take them and get out of this place!').
description(livingRoom,
            ' There is nothing useful here. Do not even dare to watch TV now!').

% Dynamic variables:
:- dynamic position/2.
:- dynamic hasPistol/2.
:- dynamic hasKeys/2.
:- dynamic hasFullEq/2.


/* ------------------------------------------------------------------------------------------------------------------------------------------------------ */
/* ---INVENTORY--- */
inventory([pistol, keys]).
showItems([First|Second]) :- write('Items: '), write(First), showItems(Second), nl.
showPistol([First|_]) :- write('Items: '), write(First), nl.
showKeys([_|Second]) :- write('Items: '), write(Second), nl. 

items :- % shows keys
    position(you, CurrentPos),
    hasKeys(you, CurrentPos),
    inventory(Item), showKeys(Item).

items :- % shows pistol
    position(you, CurrentPos),
    hasPistol(you, CurrentPos),
    inventory(Item), showPistol(Item).

items :- % shows all items
    position(you, CurrentPos),
    hasFullEq(you, CurrentPos),
    inventory(Item), showItems(Item).

items :- % shows this message, when you dont have any items on you
    writeln('You have no items on you right now...').


/* ------------------------------------------------------------------------------------------------------------------------------------------------------ */
/* ---MOVES--- */

move(items) :-
    items.

move(take) :- % take pistol
    position(you, CurrentPos),
    pistol(CurrentPos).

move(pickup) :- % pickup keys
    position(you, CurrentPos),
    keys(CurrentPos).
    
move(lookAround) :- % shows description of current position
    position(you, CurrentRoom), description(CurrentRoom, RoomDescription), writeln(RoomDescription).

move(Direction) :- % goes in specific direction
    position(you, CurrentPos),
    path(CurrentPos, NextPos, Direction),
    write('You go '), write(Direction), write('...'),
    retract(position(you, CurrentPos)),
    assert(position(you, NextPos)),
    showPosition,
    !.   

move(_) :- % default message, when invalid command was typed
    writeln('You can not go there! '),
    showPosition.


/* ------------------------------------------------------------------------------------------------------------------------------------------------------ */
/* ---SITUATIONS--- */
escape :- % win situation, when player escapes
    position(escape, CurrentPos),
    position(you, CurrentPos),
    writeln('You escaped from this scary monster. Congratulations!'), nl,
	retract(position(you, CurrentPos)),
	assert(position(you, gameOver)),
	!.
escape.

monster :- % lose situation, when player is killed by the monster
    position(monster, CurrentPos),
    position(you, CurrentPos),
    writeln('Monster cuts you with its claws to death. You got killed by monster...'), nl,
    retract(position(you, CurrentPos)),
    assert(position(you, gameOver)),
    !.
monster.

monster :- % win situation, when player kill the monster
    position(monster, CurrentPos),
    position(you, CurrentPos),
    hasPistol(you, CurrentPos),
    writeln('You start shooting towards the monster. You emptied the entire magazine. Monster falls on the ground.'),
    writeln('Congratulations. You made it. You killed the monster!'),
	retract(position(you, CurrentPos)),
	assert(position(you, gameOver)),
	!.
monster.

pistol(CurrentPos) :- % situation, when player takes pistol
    position(pistol, CurrentPos),
    position(you, CurrentPos),
    retract(hasPistol(you, default)),
    assert(hasPistol(you, _)),
    writeln('You take a pistol. Now you are ready to face this monster.'),
    !.

pistol(_) :- % situation, when there is nothingto take
    writeln('There is nothing to take!'),
    !.

keys(CurrentPos) :- % situation, when player picks up keys
    position(keys, CurrentPos),
    position(you, CurrentPos),
    retract(hasKeys(you, default)),
    assert(hasKeys(you, _)),
    writeln('You pick up the keys to the front door. You can escape now.'),
    !.

keys(_) :- % situation, when there is nothing to pick up
    writeln('There is nothing to pick up!'),
    !.

hasPistol(you, default).
hasKeys(you, default).

    
/* ------------------------------------------------------------------------------------------------------------------------------------------------------ */    
/* ---TEXT STUFF--- */
showControlls :- % shows list of available controlls
    nl,
    writeln('CONTROLLS:'),
    writeln('north		:		go to the room next to you'),
    writeln('south		:		go to the room behind you'),
    writeln('west		:		go to the room left to you'),
    writeln('east		:		go to the room right to you'),
    writeln('downstairs	:		go downstairs'),
    writeln('upstairs	:		go upstairs'),
    writeln('lookAround	:		look round in the room'),
    writeln('pickup		:		pickup keys'),
    writeln('take		:		take gun'),
    writeln('items		:		shows items').

showIntro :- % shows story intro
	nl,
    writeln('INTRO:'),
    writeln('You wake up scared inside your bed. You have dreamed about one of those terrible nightmares again.'),
    writeln('Your hand reaches for the phone quickly. You check the time. It is 3AM.'),   
    writeln('You try to sleep again, but You can not even frost your eye. You get out from your bed and walks toward the door.'),
    writeln('Then something strange happens...'),
    writeln('When your hand reaches for the door knob, you hear terrifying sound coming behind the door.'),
    writeln('The sound, like the one in your nightmares. You think, you must be dreaming again. You pinch your skin instinctively.'),
    writeln('You are not dreaming! You can hear this terrifying sound again. You can feel a chill moving down your spine.'),
    writeln('You have to check the source of these scary sounds').

showPosition :- % shows current position
    nl, 
    position(you, CurrentPos), room(CurrentPos, PosDescription), writeln(PosDescription).


/* ------------------------------------------------------------------------------------------------------------------------------------------------------ */
/* ---MAIN STUFF--- */
moveHandler :- % end of main loop
    position(you, gameOver),
    writeln('The game is over. Thanks for playing!'),
    !.

moveHandler :- % main loop
    nl,
    writeln('What will you do?'),
    read(Move),
    call(move(Move)),
    monster,
    escape,
    moveHandler.

setGame :- % sets positions of objects
    writeln('setting game...'),
    retractall(position(_,_)),
    assert(position(you, bedroom)),
    assert(position(monster, bathroom)),
    assert(position(pistol, wardrobe)),
    assert(position(keys, diningRoom)),
    assert(position(escape, garden)).

start :- % run this command, to start the game :)
    setGame,
    writeln('New game started!'),
    showControlls,
    showIntro,
    showPosition,
    moveHandler.