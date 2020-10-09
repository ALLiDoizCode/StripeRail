import Vapor
import Fluent
import Stripe

struct StripeController:RouteCollection {

    struct ChargeToken: Content {
        var token: String
    }

    func boot(routes: RoutesBuilder) throws {
        routes.post("chargeCustomer", use: chargeCustomer)
    }

    func chargeCustomer(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let charge = try req.content.decode(ChargeToken.self)
        return req.stripe.charges.create(amount: 2500, currency: .usd, source: charge.token).map { stripeCharge in
            if stripeCharge.status == .succeeded {
                return .ok
            } else {
                print("Stripe charge status: \(String(describing:stripeCharge.status?.rawValue))")
                return .badRequest
            }
        }
    }

    func payout(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let charge = try req.content.decode(ChargeToken.self)
        return req.stripe.payouts.create(amount: 2500, currency: .usd, method: .instant).map { payout in
            if payout.status == .paid {
                return .ok
            } else if payout.status == .failed {
                print("Stripe payout status: \(String(describing:payout.status?.rawValue))")
                return .badRequest
            }else {
                print("Stripe payout status: \(String(describing:payout.status?.rawValue))")
                return .ok
            }
        }
    }
}