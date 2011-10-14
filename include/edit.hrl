-define(debug(F, A), io:format("[~s:~p] " ++ F, [?MODULE, ?LINE | A])).

%% TODO: remove
-define(EDIT_TERMINAL, edit_terminal).

-record(state,
	{curwin,		 % current window
	 windows=[],		 % other windows
	 buffers=[],		 % list of buffers, most recently used at head
	 lastcmd,		 % {M, F, A} of the last command executed
	 %% for edit_extended
	 pending_cmd,
	 pending_win
	}).

%% Window: an area of the display used for viewing a particular
%% buffer, just like an emacs window.
-record(window,
	{buffer,		 % buffer being viewed
	 y,			 % screen row that this window starts at
	 width,			 % width in characters
	 height,		 % height in characters
	 start_mark,		 % mark on start of display (unique to window)
	 goal_column=0,
	 active=true,
	 id,			 % ref() - unique id
	 minibuffer=false,
	 %% fields just for the minibuffer
	 status_text,
	 prefix=""
	}).

-record(mode, {name,		 % string
	       id,		 % atom
	       keymaps}).

-define(EOL_CHAR, $$). % Character to indicate the line is chopped
