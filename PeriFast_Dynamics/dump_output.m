function Output = dump_output(Output,j,u1,u2,u3,v1,v2,v3,W,damage,lambda,t)
% Output(j).t = t;
Output(j).u1 = u1;
Output(j).u2 = u2;
Output(j).u3 = u3;
Output(j).u_mag = sqrt(u1.^2 + u2.^2 + u3.^2);
Output(j).v1 = v1;
Output(j).v2 = v2;
Output(j).v3 = v3;
Output(j).v_mag = sqrt(v1.^2 + v2.^2 + v3.^2);
Output(j).W = W;
Output(j).d = damage;
Output(j).lambda = lambda;
end