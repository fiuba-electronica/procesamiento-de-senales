function Fv=makeCameraJacobian(Xv,u,dt,type)

omegaOld=Xv(11:13);
qOld=Xv(4:7);

Fv=eye(13);

qwt=transformAnglesToQuaternion(omegaOld*dt);
Fv(4:7,4:7) = makeQuaternionByPreviousQuaternionJacobian(qwt);

if strcmp(type,'constant_velocity')
    Fv(1:3,8:10)= eye(3)*dt;
    Fv(4:7,11:13) = makeQuaternionByQuaternionOmegaMinus1Jacobian(qOld)*makeQuaternionOmegaMinus1DtByOmegaMinu1Dt(omegaOld,dt);
end

if strcmp(type,'constant_orientation')
    Fv(4:7,11:13)= zeros(4,3);
    Fv(11:13,11:13)= zeros(3,3);
end

if strcmp(type,'constant_position')
    Fv(1:3,8:10)= zeros(3,3);
    Fv(8:10,8:10)= zeros(3,3);
end

if strcmp(type,'constant_position_and_orientation')
    Fv(4:7,11:13)= zeros(4,3);
    Fv(1:3,8:10)= zeros(3,3);
    Fv(11:13,11:13)= zeros(3,3);
    Fv(8:10,8:10)= zeros(3,3);
end

end

%  // Calculate commonly used Jacobian part dq(omega * delta_t) by domega

function dqomegadt_domega=dqomegadt_domega(omega, delta_t)

  %// Modulus
  omegamod = norm(omega);

  %// Use generic ancillary functions to calculate components of Jacobian
  dqomegadt_domega(1, 1) = dq0_by_domegaA(omega(1), omegamod, delta_t);
  dqomegadt_domega(1, 2) = dq0_by_domegaA(omega(2), omegamod, delta_t);
  dqomegadt_domega(1, 3) = dq0_by_domegaA(omega(3), omegamod, delta_t);
  dqomegadt_domega(2, 1) = dqA_by_domegaA(omega(1), omegamod, delta_t);
  dqomegadt_domega(2, 2) = dqA_by_domegaB(omega(1), omega(2), omegamod, delta_t);
  dqomegadt_domega(2, 3) = dqA_by_domegaB(omega(1), omega(3), omegamod, delta_t);
  dqomegadt_domega(3, 1) = dqA_by_domegaB(omega(2), omega(1), omegamod, delta_t);
  dqomegadt_domega(3, 2) = dqA_by_domegaA(omega(2), omegamod, delta_t);
  dqomegadt_domega(3, 3) = dqA_by_domegaB(omega(2), omega(3), omegamod, delta_t);
  dqomegadt_domega(4, 1) = dqA_by_domegaB(omega(3), omega(1), omegamod, delta_t);
  dqomegadt_domega(4, 2) = dqA_by_domegaB(omega(3), omega(2), omegamod, delta_t);
  dqomegadt_domega(4, 3) = dqA_by_domegaA(omega(3), omegamod, delta_t);
  
 return
end

% // Ancillary functions: calculate parts of Jacobian dq_by_domega
% // which are repeatable due to symmetry.
% // Here omegaA is one of omegax, omegay, omegaz
% // omegaB, omegaC are the other two
% // And similarly with qA, qB, qC

function dq0_by_domegaARES=dq0_by_domegaA(omegaA, omega, delta_t)

  dq0_by_domegaARES=(-delta_t / 2.0) * (omegaA / omega) * sin(omega * delta_t / 2.0);
end

function dqA_by_domegaARES=dqA_by_domegaA(omegaA, omega, delta_t)
  dqA_by_domegaARES=(delta_t / 2.0) * omegaA * omegaA / (omega * omega) ...
                    * cos(omega * delta_t / 2.0) ...
                    + (1.0 / omega) * (1.0 - omegaA * omegaA / (omega * omega))...
                    * sin(omega * delta_t / 2.0);

return
end

function dqA_by_domegaBRES=dqA_by_domegaB(omegaA, omegaB, omega, delta_t)

  dqA_by_domegaBRES=(omegaA * omegaB / (omega * omega)) * ...
                    ( (delta_t / 2.0) * cos(omega * delta_t / 2.0) ...
                    - (1.0 / omega) * sin(omega * delta_t / 2.0) );
return 
end
