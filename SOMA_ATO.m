% ------ SOMA Simple Program       ---  Version: All To One (Original) ----
% ------ Written by: Quoc Bao DIEP ---  Email: diepquocbao@gmail.com   ----
% -----------  See more details at the end of this file  ------------------
clearvars; %clc;
disp('Hello! SOMA ATO is working, please wait... ')
tic                                                                         % Start the timer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                  U S E R    D E F I N I T I O N
% Define the Cost function, if User want to optimize the other function,
% Please change the function name, for example:  CostFunction = @(pop)      schwefelfcn(pop);
%                                           or:  CostFunction = @(pop)      ackleyfcn(pop);
%                                           or:  CostFunction = @(pop)      periodicfcn(pop);
CostFunction = @(pop)      schwefelfcn(pop');  % use this line if: population size = PopSize x Dimension
%CostFunction = @(pop)          schwefelfcn(pop);      % use this line if: population size = Dimension x PopSize

                    dimension           = 10;                               % Choose the dimension of function
% -------------- Initial Parameters of SOMA -------------------------------
                    Step                = 0.11;                             % Define the Step parameter
                    PRT                 = 0.1;                              % Define the PRT parameter
                    PopSize             = 100;                              % Define the number individuals of the population
                    PathLength          = 3.0;                              % Define the PathLength parameter
                    Migrations_Max      = 100;                              % Define the stop condition
                    Max_FEs             = 1e4*dimension;                    % Define the stop condition
% -------------- The domain (search space) of the function ----------------
                    VarMin              = -500;                             % Define the search space (lower)
                    VarMax              =  500;                             % Define the search space (upper)
%             E N D    O F   U S E R    D E F I N I T I O N
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    B E G I N    S O M A
% ------------------- Create Initial Population ---------------------------
pop            = VarMin + rand(dimension , PopSize) * (VarMax - VarMin);    % Create Initial Population, pop size = Dimension x PopSize
fitness        = CostFunction(pop);                                         % Evaluate the Initial Population, fitness size = 1 x PopSize
FEs            = PopSize;                                                   % Count the number of fitness evaluations
[the_best_cost, id]  = min(fitness); 										% Find the Global minimum fitness value
the_best_value = pop(:,id);													% Get the Global minimun position (solution values)
% ---------------- SOMA MIGRATIONS ----------------------------------------
Migration      = 0;
while    (FEs  < Max_FEs) 													% Stop Condition: when reaching Max_FEs
    Migration  = Migration + 1;                                             % Increase Migration
    % ------------ find the leader ----------------------------------------
    [min_cost,id]   = min(fitness);											% Find the index of minimum value in the fitness list
     leader         = pop(: , id);                                          % Find the Leader of current Migration, leader size = Dimention x 1
    % ------------ movement of each individual ----------------------------
    for   j = 1 : PopSize
        indi_moving = pop(:,j);                                             % Choose the individual who will move towards the leader, indi_moving size = Dimention x 1
        if j ~= id                                                          % Skip if the moving individual and the leader are the same
            offspring_path  = [];											% Create an empty path of offspring
            for     k       = 0 : Step : PathLength							% From Step to PathLength: jumping
                %----- SOMA Mutation --------------------------------------
                PRTVector      = rand(dimension,1) < PRT;                   % The same with: if rand < PRT, PRTVector = 1, else, PRTVector = 0
                %----- SOMA Crossover -------------------------------------
                offspring      =  indi_moving + (leader - indi_moving)* k .* PRTVector; % Create the offspring, offspring size = Dimention x 1
                offspring_path = [offspring_path   offspring];              % Store the offspring position, offspring_journey size = Dimention x number_of_jump (number_of_jump = ceil(PathLength/Step))
            end % END JUMPING
            %-- Check the boundary and replace the Individuals that out of the search-space
            [Dim , number_indi_journey] = size(offspring_path);
            for cl = 1 : number_indi_journey								% From column
                for rw = 1 : Dim 											% From row: Check
                    if  (offspring_path(rw,cl) < VarMin) || (offspring_path(rw,cl) > VarMax) % if outside the search range
                         offspring_path(rw,cl) = VarMin   +  rand*(VarMax - VarMin); % Randomly put it inside
                    end
                end
            end
            %----- Evaluate the offspring ---------------------------------
            new_cost              = CostFunction(offspring_path);           % Evaluate the offspring, new_cost size = 1 x PopSize
            FEs                   = FEs + number_indi_journey;              % Count the number of fitness evaluations
            %----- Choose the best offspring ------------------------------
            [min_new_cost, idz]   = min(new_cost); 							% Find the minimum fitness value of new_cost
            %----- Accepting: Place the best offspring into the current population
            if  min_new_cost     <= fitness(j)                              % Compare min_new_cost with fitness value of the moving individual
                the_best_offspring = offspring_path(: , idz);				% Get the position values (solution values) of the min_new_cost
                pop(:,j)          = the_best_offspring;						% Replace the moving individual position (solution values)
                fitness(j)        = min_new_cost;							% Replace the moving individual fitness value
				%----- Update the global best value -----------------------
                if  min_new_cost     <= the_best_cost						% Compare Current minimum fitness with Global minimum fitness
                    the_best_cost     = min_new_cost;						% Update Global minimun fitness value
                    the_best_value    = the_best_offspring;                 % Update Global minimun position, the_best_value size = Dimention x 1
                end
            end
        end % END if
    end  % END PopSize   (For Loop)
end   % END MIGRATIONS (While Loop)
time = toc;
%% Show the information to User
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['Stop at Migration :  ' num2str(Migration)])
disp(['The number of FEs :  ' num2str(FEs)])
disp(['Processing time   :  ' num2str(time)])
disp(['The best cost     :  ' num2str(the_best_cost)])
disp(['Solution values   :  ']), disp(the_best_value)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This algorithm is programmed according to the descriptions in the papers listed below:
% Link of paper: https://link.springer.com/chapter/10.1007/978-3-319-28161-2_1
% I. Zelinka and L. Jouni, "SOMA–self-organizing migrating algorithm mendel," in 6th International Conference on Soft Computing, Brno, Czech Republic, 2000.
% I. Zelinka, "SOMA–self-organizing migrating algorithm," in New optimization techniques in engineering. Springer, 2004, pp. 167–217.
% I. Zelinka, "SOMA–self-organizing migrating algorithm," in Self-Organizing Migrating Algorithm. Springer, 2016, pp. 3–49.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% LIST OF COST FUNCTIONS (Need to optimize):

% You will replace these functions with your own that describes the problem you need to optimize for.
%--------------------------------------------------------------------------
% Schwefel function:
% schwefelfcn accepts a matrix of size M-by-N and returns a vetor SCORES
% of size M-by-1 in which each row contains the function value for each row of X.
function scores = schwefelfcn(x)
    n = size(x, 2);
    scores = 418.9829 * n - (sum(x .* sin(sqrt(abs(x))), 2));
end
%--------------------------------------------------------------------------
% Ackley function:
% ackleyfcn accepts a matrix of size M-by-N and returns a vetor SCORES
% of size M-by-1 in which each row contains the function value for each row of X.
function scores = ackleyfcn(x)
    n = size(x, 2);
    ninverse = 1 / n;
    sum1 = sum(x .^ 2, 2);
    sum2 = sum(cos(2 * pi * x), 2);
    scores = 20+exp(1)-(20*exp(-0.2*sqrt(ninverse*sum1)))-exp(ninverse*sum2);
end
%--------------------------------------------------------------------------
% Periodic function:
% periodicfcn accepts a matrix of size M-by-N and returns a vetor SCORES
% of size M-by-1 in which each row contains the function value for each row of X.
function scores = periodicfcn(x)
    sin2x = sin(x) .^ 2;
    sumx2 = sum(x .^2, 2);
    scores = 1 + sum(sin2x, 2) -0.1 * exp(-sumx2);
end